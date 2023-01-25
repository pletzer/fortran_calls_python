program test_self_descr_array

    use iso_c_binding, only: c_loc, c_f_pointer
    use self_descr_array_mod

    implicit none
    include 'netcdf.inc'

    real(8), pointer :: ra(:, :)
    integer, pointer :: ia(:)
    type(self_descr_array_type) :: obj_ra, obj_ia, obj_rb, obj_ib
    real(8), pointer :: rb(:, :)
    integer, pointer :: ib(:)
    integer :: i, j, k, ier, ncid, ra_id, ia_id, status

    allocate(ra(2, 3), ia(6))

    ! fill in the array
    k = 0
    do j = 1, size(ra, 2)
        do i = 1, size(ra, 1)
            ra(i, j) = k
            ia(k + 1) = k
            k = k + 1
        enddo
    enddo

    ! create the object
    call sda_create(obj_ra, 'ra', 'r8', shape(ra), c_loc(ra))
    call sda_create(obj_ia, 'ia', 'i', shape(ia), c_loc(ia))

    ! write some input to file
    status = nf_create('test_input.nc', NF_NETCDF4, ncid)
    if (status /= nf_noerr) call exit(1)

    call sda_define_data(obj_ra, ncid, ra_id, ier)
    if (ier /= 0) call exit(2)
    call sda_define_data(obj_ia, ncid, ia_id, ier)
    if (ier /= 0) call exit(2)

    status = nf_enddef(ncid)
    if (status /= nf_noerr) then
        write(0,*) nf_strerror(status)
        ier = ier + 1
    endif


    call sda_write_data(obj_ra, ncid, ra_id, ier)
    if (ier /= 0) call exit(3)
    call sda_write_data(obj_ia, ncid, ia_id, ier)
    if (ier /= 0) call exit(3)

    status = nf_close(ncid)
    if (status /= nf_noerr) call exit(1)

    call sda_destroy(obj_ra)
    call sda_destroy(obj_ia)

    ! now read the data back in
    call sda_create_from_file(obj_ra, 'test_input.nc', 'ra', ier)
    if (ier /= 0) call exit(4)
    write(0,*)'obj_ra%type=', obj_ra%type, ' obj_ra%dims=', obj_ra%dims

    call c_f_pointer(obj_ra%address, ra, obj_ra%dims)
    write(0,*)'ra = ', ra

    call sda_create_from_file(obj_ia, 'test_input.nc', 'ia', ier)
    if (ier /= 0) call exit(4)
    write(0,*)'obj_ia%type=', obj_ia%type, ' obj_ia%dims=', obj_ia%dims

    call c_f_pointer(obj_ia%address, ia, obj_ia%dims)
    write(0,*)'ia = ', ia

    call sda_destroy(obj_ra)
    call sda_destroy(obj_ia)

end program test_self_descr_array