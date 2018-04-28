#include <efi.h>
#include <efilib.h>

#ifndef EFICALLS_H
#define EFICALLS_H

EFI_SYSTEM_TABLE *sys_table;
EFI_BOOT_SERVICES *boot;
EFI_RUNTIME_SERVICES *runtime;

static inline EFI_STATUS allocate_pages(EFI_ALLOCATE_TYPE atype, EFI_MEMORY_TYPE mtype, UINTN num_pages,
                                        EFI_PHYSICAL_ADDRESS *memory)
{
    return uefi_call_wrapper(boot->AllocatePages, 4, atype, mtype, num_pages, memory);
}

static inline EFI_STATUS free_pages(EFI_PHYSICAL_ADDRESS memory, UINTN num_pages)
{
    return uefi_call_wrapper(boot->FreePages, 2, memory, num_pages);
}

static inline EFI_STATUS allocate_pool(EFI_MEMORY_TYPE type, UINTN size, void **buffer)
{
    return uefi_call_wrapper(boot->AllocatePool, 3, type, size, buffer);
}

static inline EFI_STATUS free_pool(void *buffer)
{
    return uefi_call_wrapper(boot->FreePool, 1, buffer);
}

static inline EFI_STATUS get_memory_map(UINTN *size, EFI_MEMORY_DESCRIPTOR *map, UINTN *key, UINTN *descr_size,
                                        UINT32 *descr_version)
{
    return uefi_call_wrapper(boot->GetMemoryMap, 5, size, map, key, descr_size, descr_version);
}

static inline EFI_STATUS exit_boot_services(EFI_HANDLE image, UINTN key)
{
    return uefi_call_wrapper(boot->ExitBootServices, 2, image, key);
}

static inline EFI_STATUS exit(EFI_HANDLE image, EFI_STATUS status, UINTN size, CHAR16 *reason)
{
    return uefi_call_wrapper(boot->Exit, 4, image, status, size, reason);
}

static const CHAR16 *memory_types[] = {
    L"EfiReservedMemoryType",
    L"EfiLoaderCode",
    L"EfiLoaderData",
    L"EfiBootServicesCode",
    L"EfiBootServicesData",
    L"EfiRuntimeServicesCode",
    L"EfiRuntimeServicesData",
    L"EfiConventionalMemory",
    L"EfiUnusableMemory",
    L"EfiACPIReclaimMemory",
    L"EfiACPIMemoryNVS",
    L"EfiMemoryMappedIO",
    L"EfiMemoryMappedIOPortSpace",
    L"EfiPalCode",
    L"EfiMaxMemoryType",
};

static inline const CHAR16 *memory_type_to_str(UINT32 type)
{
    if(type > (sizeof(memory_types) / sizeof(CHAR16))) {
        return L"Unknown";
    }

    return memory_types[type];
}

EFI_STATUS memory_map(EFI_MEMORY_DESCRIPTOR **map_buf, UINTN *map_size, UINTN *map_key, UINTN *desc_size,
                      UINT32 *desc_version);

#endif // EFICALLS_H
