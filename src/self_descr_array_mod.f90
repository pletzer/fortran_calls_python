module self_descr_array_mod
use iso_c_binding, only: c_ptr

type self_descr_array_type
    character(len=128):: name
    character(len=2):: type
    integer, allocatable :: dims(:)
    type(c_ptr) :: address
end type self_descr_array_type

contains

function create(name, type, dims, data) result(obj)
    use iso_c_binding, only: c_loc, c_ptr
    implicit none
    character(len=128), intent(in) :: name
    character(len=2), intent(in) :: type
    integer(8) :: dims(:)
    type(c_ptr), pointer, intent(in) :: data

    type(self_descr_array_type), pointer :: obj

    integer :: ndims

    allocate(obj)
    obj%name = name
    obj%type = type
    allocate(obj%dims(size(dims)))
    obj%dims = dims
    obj%address = c_loc(data)

end function create

subroutine destroy(obj)
    implicit none
    type(self_descr_array_type), pointer :: obj
    deallocate(obj%dims)
    deallocate(obj)
end subroutine destroy

end module self_descr_array_mod