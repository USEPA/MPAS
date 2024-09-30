        program test

          use get_env_module

          implicit none

          integer, parameter :: nfiles = 3
          integer, parameter :: ounit1  = 30
          integer, parameter :: ounit2  = 31
          character(2), parameter :: type(nfiles) = (/ 'GC', 'AE', 'NR' /)
          character(7), parameter :: infile(nfiles) = (/ 'infile1', 'infile2', 'infile3' /)

          character (200) :: ofname1, ofname2
          integer :: i
          logical :: coupled

          ofname1 = 'out1.dat'
          open (unit=ounit1, file=ofname1, status='new')
          ofname2 = 'out2.dat'
          open (unit=ounit2, file=ofname2, status='new')

          call get_env (coupled, 'coupled', .false.)

          do i = 1, nfiles
             call process (infile(i), type(i), ounit1, ounit2)
          end do

          if (coupled) then
             call process (' ', 'CM', ounit1, ounit2)
          end if

          close (ounit1)
          close (ounit2)

        end program test

! ---------------------------------------------------------------------
        subroutine extract (buf, vname, vlen, mode)

          implicit none

          character (200), intent(in)    :: buf
          character (16), intent(out)    :: vname
          integer, intent(out)           :: vlen
          logical, intent(out), optional :: mode(3)

          integer :: i, count, start, end
          logical :: done

          i = 1
          done = .false.
          do while (.not. done)
             i = i + 1
             if (buf(i:i) == "'") then
                done = .true.
                vlen = i - 2
                read (buf(2:i-1), *) vname
             end if
          end do

          if (present(mode)) then
             count = 0
             done = .false.
             do while (.not. done)
                i = i + 1
                if (buf(i:i) == ",") then
                   count = count + 1
                   if (count == 2) then
                      start = i + 1
                   else if (count == 5) then
                      end = i - 1
                      done = .true.
                   end if
                end if
             end do
             read (buf(start:end), *) mode
          end if

        end subroutine extract

! ---------------------------------------------------------------------
!       subroutine construct_fmt1 (vname, vlen, ounit, type, cmode)
        subroutine construct_fmt1 (vname, ounit, type, cmode)

          implicit none

          character (16), intent(in)          :: vname
!         integer, intent(in)                 :: vlen, ounit
          integer, intent(in)                 :: ounit
          character (2), intent(in)           :: type
          character (1), intent(in), optional :: cmode

          character (200) :: buf
          character (16)  :: loc_vname, myfmt
          integer :: s, e, vlen, buf_len

          write (ounit, *)

          loc_vname = vname

          vlen = len_trim(loc_vname)

          buf = ' '
          buf(25:35) = '<var name="'
          s = 36
          e = 36 + vlen - 1
          buf(s:e) = trim(loc_vname)
          s = e + 1
          e = s
          buf(s:e) = '"'

          if ((type == 'GC') .or. (type == 'NR')) then
             buf(51:91) = 'array_group="passive"        units="ppmV"'
          else if ((type == 'AE') .or. (type == 'CM')) then
             if ((loc_vname == 'NUMATKN') .or.        &
                 (loc_vname == 'NUMACC') .or.         &
                 (loc_vname == 'NUMCOR')) then
                buf(51:90) = 'array_group="passive"        units="m-3"'
             else if ((loc_vname == 'SRFATKN') .or.   &
                      (loc_vname == 'SRFACC') .or.    &
                      (loc_vname == 'SRFCOR')) then
                buf(51:89) = 'array_group="passive"        units="m2"'
             else
!               buf(51:93) = 'array_group="passive"        units="ug m-3"'
                buf(51:89) = 'array_group="passive"        units="ug"'
             end if
          end if

          buf_len = len_trim(buf)
          write (myfmt, '(a2, i3.3, a1)') '(a', buf_len, ')' 
          write (ounit, myfmt) buf

          buf = ' '
          buf(30:42) = 'description="'

          s = 43
          e = 43 + vlen - 1
          buf(s:e) = trim(loc_vname)
          s = e + 1
          e = s + 16
          buf(s:e) = ' concentration"/>'

          buf_len = len_trim(buf)
          write (myfmt, '(a2, i3.3, a1)') '(a', buf_len, ')' 
          write (ounit, myfmt) buf

        end subroutine construct_fmt1

! ---------------------------------------------------------------------
!       subroutine construct_fmt2 (vname, vlen, ounit, type, cmode)
        subroutine construct_fmt2 (vname, ounit, type, cmode)

          implicit none

          character (16), intent(in)          :: vname
!         integer, intent(in)                 :: vlen, ounit
          integer, intent(in)                 :: ounit
          character (2), intent(in)           :: type
          character (1), intent(in), optional :: cmode

          character (200) :: buf
          character (16)  :: myfmt
          integer :: s, e, vlen, buf_len

          write (ounit, *)

          vlen = len_trim(vname)

          buf = ' '
          buf(25:40) = '<var name="tend_'

          s = 41
          e = 41 + vlen - 1
          buf(s:e) = trim(vname)
          s = e + 1
          e = s
          buf(s:e) = '"'

          buf(56:69) = 'name_in_code="'

          s = 70
          e = 70 + vlen - 1
          buf(s:e) = trim(vname)
          s = e + 1
          e = s
          buf(s:e) = '"'

          if ((type == 'GC') .or. (type == 'NR')) then
             buf(85:127) = 'array_group="passive"   units="ppmV s^{-1}"'
          else if ((type == 'AE') .or. (type == 'CM')) then
             if ((vname == 'NUMATKN') .or.        &
                 (vname == 'NUMACC') .or.         &
                 (vname == 'NUMCOR')) then
                buf(85:126) = 'array_group="passive"   units="m-3 s^{-1}"'
             else if ((vname == 'SRFATKN') .or.   &
                      (vname == 'SRFACC') .or.    &
                      (vname == 'SRFCOR')) then
                         buf(85:125) = 'array_group="passive"   units="m2 s^{-1}"'
             else
!               buf(85:129) = 'array_group="passive"   units="ug m-3 s^{-1}"'
                buf(85:125) = 'array_group="passive"   units="ug s^{-1}"'
             end if
          end if

          buf_len = len_trim(buf)
          write (myfmt, '(a2, i3.3, a1)') '(a', buf_len, ')' 
          write (ounit, myfmt) buf

          buf = ' '
          buf(30:54) = 'description="Tendency of '

          s = 55
          e = 55 + vlen - 1
          buf(s:e) = trim(vname)
          s = e + 1
          e = s + 16
          buf(s:e) = ' concentration"/>'

          buf_len = len_trim(buf)
          write (myfmt, '(a2, i3.3, a1)') '(a', buf_len, ')' 
          write (ounit, myfmt) buf

        end subroutine construct_fmt2

! ---------------------------------------------------------------------
        subroutine process (file, type, ounit1, ounit2)

          use get_env_module

          implicit none

          character (7), intent(in) :: file
          character (2), intent(in) :: type
          integer, intent(in)       :: ounit1, ounit2

          integer, parameter :: iunit = 10, n_cm_vname = 7
          character, parameter :: cmode(3) = (/'I', 'J', 'K' /)
          character (9), parameter :: cm_vname(n_cm_vname) =         &
            (/ 'WS       ', 'IS       ', 'EC       ', 'SEASALT  ',   &
               'WATER    ', 'DIAMETERS', 'SD       '             /)

          character (200) :: fname, buf
          character (16) :: vname, vname2, myfmt
          logical :: start_body, end_body, mode(3)
          integer :: vlen, buf_len, s, e, i, v

          interface
            subroutine extract (buf, vname, vlen, mode)
              character (200), intent(in)    :: buf
              character (16), intent(out)    :: vname
              integer, intent(out)           :: vlen
              logical, intent(out), optional :: mode(3)
            end subroutine extract

!           subroutine construct_fmt1 (vname, vlen, ounit, type, cmode)
            subroutine construct_fmt1 (vname, ounit, type, cmode)
              character (16), intent(in)          :: vname
!             integer, intent(in)                 :: vlen, ounit
              integer, intent(in)                 :: ounit
              character (2), intent(in)           :: type
              character (1), intent(in), optional :: cmode
            end subroutine construct_fmt1

!           subroutine construct_fmt2 (vname, vlen, ounit, type, cmode)
            subroutine construct_fmt2 (vname, ounit, type, cmode)
              character (16), intent(in)          :: vname
!             integer, intent(in)                 :: vlen, ounit
              integer, intent(in)                 :: ounit
              character (2), intent(in)           :: type
              character (1), intent(in), optional :: cmode
            end subroutine construct_fmt2
          end interface

          call get_env (fname, file, ' ')

          if (fname == ' ') then
             if (type == 'CM') then   ! coupled model variables
                do v = 1, n_cm_vname
                   do i = 1, 3
                      if (i == 1) then
                         vname2 = trim(cm_vname(v)) // '_1'
                      else if (i == 2) then
                         vname2 = trim(cm_vname(v)) // '_2'
                      else
                         vname2 = trim(cm_vname(v)) // '_3'
                      end if
                      call construct_fmt1 (vname2, ounit1, type)
                      call construct_fmt2 (vname2, ounit2, type)
                   end do
                end do
             else
                write (6, *) 'Abort: ', trim(file), ' was not set'
                stop
             end if
          else
             open (unit=iunit, file=fname, status='old')
             start_body = .false.
             end_body = .false.
             do while (.not. end_body)
                read (iunit, '(a200)') buf
                if (buf(1:1) == "'") then
                   if (.not. start_body) then
                      start_body = .true.
                   end if
                   if ((type == 'GC') .or. (type == 'NR')) then
                      call extract (buf, vname, vlen)
!                     call construct_fmt1 (vname, vlen, ounit1, type)
!                     call construct_fmt2 (vname, vlen, ounit2, type)
                      call construct_fmt1 (vname, ounit1, type)
                      call construct_fmt2 (vname, ounit2, type)
                   else   ! (type == 'AE')
                      call extract (buf, vname, vlen, mode)
                      do i = 1, 3
                         if (mode(i)) then
!                           call construct_fmt1 (vname, vlen, ounit1, type, cmode(i))
!                           call construct_fmt2 (vname, vlen, ounit2, type, cmode(i))
                            if ((vname == 'NUM') .or. (vname == 'SRF')) then
                               if (i == 1) then
                                  vname2 = trim(vname) // 'ATKN'
                               else if (i == 2) then
                                  vname2 = trim(vname) // 'ACC'
                               else
                                  vname2 = trim(vname) // 'COR'
                               end if
                            else if ((vname == 'ACORS') .or.     &
                                     (vname == 'ASOIL') .or.     &
                                     (vname == 'ASEACAT')) then
                               vname2 = vname
                            else
                               if (i == 1) then
                                  vname2 = trim(vname) // 'I'
                               else if (i == 2) then
                                  vname2 = trim(vname) // 'J'
                               else
                                  vname2 = trim(vname) // 'K'
                               end if
                            end if
                            call construct_fmt1 (vname2, ounit1, type)
                            call construct_fmt2 (vname2, ounit2, type)
                         end if
                      end do
                   end if
                else
                   if (start_body) then
                      end_body = .true.
                   end if
                end if

             end do
          end if

        end subroutine process
