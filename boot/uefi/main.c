#include <efi.h>
#include <efilib.h>
#include "eficalls.h"

EFI_SYSTEM_TABLE *sys_table;
EFI_BOOT_SERVICES *boot;
EFI_RUNTIME_SERVICES *runtime;

EFI_STATUS EFIAPI efi_main(EFI_HANDLE ImageHandle, EFI_SYSTEM_TABLE *SystemTable)
{
    InitializeLib(ImageHandle, SystemTable);
    sys_table = SystemTable;
    boot = sys_table->BootServices;
    runtime = sys_table->RuntimeServices;

    // Check that header is the correct size
    if(CheckCrc(sys_table->Hdr.HeaderSize, &sys_table->Hdr) != TRUE) {
        return EFI_LOAD_ERROR;
    }

    set_screen_attributes(EFI_LIGHTGRAY | EFI_BACKGROUND_BLUE);
    clear_screen();
    Print(L"\n");

    EFI_MEMORY_DESCRIPTOR *buf;
    UINTN desc_size;
    UINT32 desc_version;
    UINTN size;
    UINTN map_key;

    EFI_STATUS err = memory_map(&buf, &size, &map_key, &desc_size, &desc_version);

    if(err != EFI_SUCCESS) {
        Print(L"Failed to get memory map!\n");
        return EFI_LOAD_ERROR;
    } else {
        Print(L"Got memory map!\n");
    }

    Print(L"Memory map size: %d\n", size);
    Print(L"Descriptor version: %d\n", desc_version);
    Print(L"Descriptor size: %d\n", desc_size);

    EFI_MEMORY_DESCRIPTOR *desc = buf;
    uint32_t total_pages = 0;

    for(int i = 0; (void *)desc < (void *)buf + size; i++) {
        UINTN mapping_size = desc->NumberOfPages * EFI_PAGE_SIZE;
        total_pages += desc->NumberOfPages;

        Print(L"[#%.2d] Type: %s\n", i, memory_type_to_str(desc->Type));
        Print(L"      Attr: 0x%016llx\n", desc->Attribute);
        Print(L"      Phys: [0x%016llx - 0x%016llx]\n", desc->PhysicalStart, desc->PhysicalStart + mapping_size);
        Print(L"      Virt: [0x%016llx - 0x%016llx]\n", desc->VirtualStart, desc->VirtualStart + mapping_size);

        desc = (void *)desc + desc_size;
    }

    Print(L"Total number of pages: 0x%016llx\n", total_pages);
    Print(L"Total memory: 0x%016llx\n", total_pages * EFI_PAGE_SIZE);
    free_pool(buf);

    return EFI_SUCCESS;
}

EFI_STATUS memory_map(EFI_MEMORY_DESCRIPTOR **map_buf, UINTN *map_size, UINTN *map_key, UINTN *desc_size,
                      UINT32 *desc_version)
{
    EFI_STATUS err;
    *map_size = sizeof(**map_buf) * 32;

    err = EFI_BUFFER_TOO_SMALL;
    while (err == EFI_BUFFER_TOO_SMALL) {
        err = allocate_pool(EfiLoaderData, *map_size, (void **)map_buf);
        if(err != EFI_SUCCESS) {
            Print(L"Failed to allocate pool for memory map");
            return err;
        }

        err = get_memory_map(map_size, *map_buf, map_key, desc_size, desc_version);
        if (err == EFI_BUFFER_TOO_SMALL) {
                free_pool((void *)*map_buf);
                *map_size += sizeof(**map_buf);
        }
    }

    if (err != EFI_SUCCESS) {
        Print(L"Failed to get memory map");
    }

    return err;
}
