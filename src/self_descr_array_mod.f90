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
    integer, intent(in) :: dims(:)
    type(c_ptr), value :: data_address

    obj%name = trim(name)
    obj%type = type
    allocate(obj%dims(size(dims)))
    obj%dims = dims
    obj%address = data_address

end subroutine sda_create

subroutine sda_create_from_file(obj, filename, name, ier)
    use iso_c_binding, only: c_loc, c_ptr
    implicit none
    include 'netcdf.inc'
    type(self_descr_array_type) :: obj
    character(len=*), intent(in) :: filename
    character(len=*), intent(in) :: name
    integer, intent(out) :: ier

    integer :: status, n, ncid, varid, ndims, xtype, natts, i
    integer, allocatable :: dim_ids(:)
    character(len=128) :: varname
    real(8), pointer :: rdata(:)
    integer, pointer :: idata(:)

    ier = 0
    status = nf_open(filename, nf_nowrite, ncid)
    if (status /= nf_noerr) then
        write(0,*) nf_strerror(status)
        ier = ier + 1
    endif

    status = nf_inq_varid(ncid, trim(name), varid)
    if (status /= nf_noerr) then
        write(0,*) nf_strerror(status)
        ier = ier + 1
    endif

    status = nf_inq_varndims(ncid, varid, ndims)
    if (status /= nf_noerr) then
        write(0,*) nf_strerror(status)
        ier = ier + 1
    endif

    allocate(dim_ids(ndims))
    allocate(obj%dims(ndims))

    status = nf_inq_var(ncid, varid, varname, xtype, ndims, dim_ids, natts)
    if (status /= nf_noerr) then
        write(0,*) nf_strerror(status)
        ier = ier + 1
    endif

    do i = 1, ndims
        status = nf_inq_dimlen(ncid, dim_ids(i), obj%dims(i))
        if (status /= nf_noerr) then
            write(0,*) nf_strerror(status)
            ier = ier + 1
        endif
    enddo

    ! read the data
    n = product(obj%dims)
    if (xtype == nf_double) then
        allocate(rdata(n))
        status = nf_get_var_double(ncid, varid, rdata)
        if (status /= nf_noerr) then
            write(0,*) nf_strerror(status)
            ier = ier + 1
        endif
        obj%address = c_loc(rdata)
        obj%type = 'r8'
    else if (xtype == nf_int) then
        allocate(idata(n))
        status = nf_get_var_int(ncid, varid, idata)
        if (status /= nf_noerr) then
            write(0,*) nf_strerror(status)
            ier = ier + 1
        endif
        obj%address = c_loc(idata)
        obj%type = 'i'
    else 
        ! error, unknown/unsupported data type
        ier = ier + 1
    endif

    status = nf_close(ncid)
    if (status /= nf_noerr) then
        write(0,*) nf_strerror(status)
        ier = ier + 1
    endif

end subroutine sda_create_from_file

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
        status = nf_def_dim(ncid, trim(dim_name), obj%dims(i), dim_ids(i))
        if(status /= nf_noerr) then
            write(0,*) nf_strerror(status)
            ier = ier + 1
        endif
    enddo

    ! define the variable
    nc_type = nf_double
    if (obj%type == 'i') then
        ! currently supporting only real(8) and integer types
        nc_type = nf_int
    endif
    status = nf_def_var(ncid, trim(obj%name), nc_type, size(dim_ids), dim_ids, varid)
    if(status /= nf_noerr) then
        write(0,*) nf_strerror(status)
        ier = ier + 1
    endif

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

    n = product(obj%dims)

    if (obj%type == 'r8') then
        call c_f_pointer(obj%address, rdata, [n])
        status = nf_put_var_double(ncid, varid, rdata)
        if (status /= nf_noerr) then
            write(0,*) nf_strerror(status)
            ier = ier + 1
        endif
    else if (obj%type == 'i') then
        call c_f_pointer(obj%address, idata, [n])
        status = nf_put_var_int(ncid, varid, idata)
        if (status /= nf_noerr) ier = ier + 1
    else
        ! error
        if (status /= nf_noerr) then
            ier = -1
        endif
    endif

end subroutine sda_write_data

end module self_descr_array_mod