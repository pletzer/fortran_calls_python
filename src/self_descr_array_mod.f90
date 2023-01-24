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

    obj%name = trim(name)
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

subroutine sda_define_data(obj, ncid, varid, ier)
    implicit none
    include 'netcdf.inc'
    type(self_descr_array_type) :: obj
    integer, intent(in) :: ncid
    integer, intent(out) :: varid
    integer, intent(out) :: ier
    integer :: status, nc_type, ndims, i
    integer, allocatable :: dim_ids(:)
    character(len=128) :: dim_name, i_str

    ier = 0

    ! define the dimensions
    ndims = size(obj%dims)
    allocate(dim_ids(ndims))
    do i = 1, ndims
        write(i_str, '(I1)') i
        dim_name = 'dim_' // trim(obj%name) // '_' //trim(i_str)
        write(0, *) 'i = ', i, ' dim_name = ', trim(dim_name), ' dim = ', obj%dims(i)
        status = nf_def_dim(ncid, trim(dim_name), obj%dims(i), dim_ids(i))
        if(status /= nf_noerr) then
            write(0,*) nf_strerror(status)
            ier = ier + 1
        endif
    enddo
    write(0,*),'done defining dims dim_ids = ', dim_ids

    ! define the variable
    nc_type = nf_double
    if (obj%type == 'i') then
        ! currently supporting only real(8) and integer types
        nc_type = nf_int
    endif
    write(0,*) 'defining the var, trim(obj%name)=', trim(obj%name), ' nc_type=', nc_type, ' dim_ids=', dim_ids
    status = nf_def_var(ncid, trim(obj%name), nc_type, size(dim_ids), dim_ids, varid)
    write(0,*) 'status = ', status
    if(status /= nf_noerr) then
        write(0,*) nf_strerror(status)
        ier = ier + 1
    endif
    write(0,*) 'done defining the var varid=', varid

end subroutine sda_define_data

subroutine sda_write_data(obj, ncid, varid, ier)
    use iso_c_binding, only : c_f_pointer
    implicit none
    include 'netcdf.inc'
    type(self_descr_array_type) :: obj
    integer, intent(in) :: ncid
    integer, intent(in) :: varid
    integer, intent(out) :: ier
    integer :: status, n
    real(8), pointer :: rdata(:)
    integer, pointer :: idata(:)

    ier = 0

    status = nf_enddef(ncid)
    if (status /= nf_noerr) then
        write(0,*) nf_strerror(status)
        ier = ier + 1
    endif

    n = product(obj%dims)

    write(0,*) 'n=', n, ' obj%type=', obj%type, 'ncid=', ncid, 'varid=', varid
    if (obj%type == 'r8') then
        call c_f_pointer(obj%address, rdata, [n])
        write(0,*) 'rdata = ', rdata
        status = nf_put_var_double(ncid, varid, rdata)
        if (status /= nf_noerr) then
            write(0,*) nf_strerror(status)
            ier = ier + 1
        endif
    else if (obj%type == 'i') then
        ! TO DO
        ! call c_f_pointer(obj%address, idata, [n])
        ! status = nf_put_var_int(ncid, varid, idata)
        ! if (status /= nf_noerr) ier = ier + 1
    else
        ! error
        if (status /= nf_noerr) then
            ier = -1
        endif
    endif
    write(0,*)'done writing the data'

end subroutine sda_write_data

end module self_descr_array_mod