program test_self_descr_array

    use iso_c_binding, only: c_loc
    use self_descr_array_mod

    implicit none
    include 'netcdf.inc'

    real(8), target :: a(2, 3)
    type(self_descr_array_type) :: obj
    integer :: i, j, ier, ncid, varid, status

    ! fill in the array
    do j = 1, size(a, 2)
        do i = 1, size(a, 1)
            a(i, j) = i * 10*j
        enddo
    enddo

    ! create the object
    call sda_create(obj, 'a', 'r8', shape(a), c_loc(a))

    ! write some input to file
    status = nf_create('test_input.nc', NF_NETCDF4, ncid)
    if (status /= nf_noerr) call exit(1)

    call sda_define_data(obj, ncid, varid, ier)
    if (ier /= 0) call exit(2)

    call sda_write_data(obj, ncid, varid, ier)
    if (ier /= 0) call exit(3)

    status = nf_close(ncid)
    if (status /= nf_noerr) call exit(1)

    call sda_destroy(obj)



end program test_self_descr_array