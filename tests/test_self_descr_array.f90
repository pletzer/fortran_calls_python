program test_self_descr_array
	use iso_c_binding, only: c_loc
    use self_descr_array_mod
    implicit none
    real(8), pointer :: a(:, :)
    type(self_descr_array_type), pointer :: obj

    allocate(a(2, 3))
    obj = sda_create('a', 'r8', shape(a), c_loc(a))
    call sda_destroy(obj)



end program test_self_descr_array