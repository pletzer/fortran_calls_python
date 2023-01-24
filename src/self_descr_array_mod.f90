module self_descr_array_mod
use iso_c_binding, only: c_ptr

type self_descr_array_type
    character(len=128):: name
    character(len=2):: type
    integer, allocatable :: dims(:)
    type(c_ptr) :: address
end type self_descr_array_type

contains

subroutine sda_create(obj, name, type, dims, data_address)
    use iso_c_binding, only: c_loc, c_ptr
    implicit none
    type(self_descr_array_type) :: obj
    character(len=*), intent(in) :: name
    character(len=*), intent(in) :: type
    integer :: dims(:)
    type(c_ptr), value :: data_address

    obj%name = name
    obj%type = type
    allocate(obj%dims(size(dims)))
    obj%dims = dims
    obj%address = data_address

end subroutine sda_create

subroutine sda_destroy(obj)
    implicit none
    type(self_descr_array_type) :: obj
    deallocate(obj%dims)
end subroutine sda_destroy

end module self_descr_array_mod