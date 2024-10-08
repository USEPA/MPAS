! Copyright (c) 2013,  Los Alamos National Security, LLC (LANS)
! and the University Corporation for Atmospheric Research (UCAR).
!
! Unless noted otherwise source code is licensed under the BSD license.
! Additional copyright and license information can be found in the LICENSE file
! distributed with this code, or at http://mpas-dev.github.com/license.html
!
!=================================================================================================================
 module mpas_atmphys_packages
 use mpas_kind_types
 use mpas_derived_types,only : mpas_pool_type,mpas_io_context_type,MPAS_LOG_ERR
 use mpas_pool_routines,only : mpas_pool_get_config,mpas_pool_get_package
 use mpas_log,only : mpas_log_write

 implicit none
 private
 public:: atmphys_setup_packages

!mpas_atmphys_packages contains the definitions of all physics packages.
!Laura D. Fowler (laura@ucar.edu) / 2016-03-10.


 contains


!=================================================================================================================
 function atmphys_setup_packages(configs,packages,iocontext) result(ierr)
!=================================================================================================================

!inout arguments:
 type (mpas_pool_type), intent(inout) :: configs
 type (mpas_pool_type), intent(inout) :: packages
 type (mpas_io_context_type), intent(inout) :: iocontext

!local variables:
 character(len=StrKIND),pointer:: config_microp_scheme
 character(len=StrKIND),pointer:: config_convection_scheme
 character(len=StrKIND),pointer:: config_pbl_scheme
 logical,pointer:: mp_kessler_in,mp_thompson_in,mp_wsm6_in
 logical,pointer:: cu_grell_freitas_in,cu_kain_fritsch_in,cu_tiedtke_in
 logical,pointer:: bl_mynn_in,bl_ysu_in,bl_acm_in

 integer :: ierr

!-----------------------------------------------------------------------------------------------------------------
!call mpas_log_write('')
!call mpas_log_write('--- enter subroutine atmphys_setup_packages:')

 ierr = 0

 call mpas_log_write('----- Setting up package variables -----')
 call mpas_log_write('')

!--- initialization of all packages for parameterizations of cloud microphysics:

 call mpas_pool_get_config(configs,'config_microp_scheme',config_microp_scheme)

 nullify(mp_kessler_in)
 call mpas_pool_get_package(packages,'mp_kessler_inActive',mp_kessler_in)

 nullify(mp_thompson_in)
 call mpas_pool_get_package(packages,'mp_thompson_inActive',mp_thompson_in)

 nullify(mp_wsm6_in)
 call mpas_pool_get_package(packages,'mp_wsm6_inActive',mp_wsm6_in)

 if(.not.associated(mp_kessler_in)  .or. &
    .not.associated(mp_thompson_in) .or. &
    .not.associated(mp_wsm6_in)) then
    call mpas_log_write('====================================================================================',messageType=MPAS_LOG_ERR)
    call mpas_log_write('* Error while setting up packages for cloud microphysics options in atmosphere core.',messageType=MPAS_LOG_ERR)
    call mpas_log_write('====================================================================================',messageType=MPAS_LOG_ERR)
    ierr = 1
    return
 endif

 mp_kessler_in           = .false.
 mp_thompson_in          = .false.
 mp_wsm6_in              = .false.

 if(config_microp_scheme == 'mp_kessler') then
    mp_kessler_in = .true.
 elseif(config_microp_scheme == 'mp_thompson') then
    mp_thompson_in = .true.
 elseif(config_microp_scheme == 'mp_wsm6') then
    mp_wsm6_in = .true.
 endif

 call mpas_log_write('    mp_kessler_in           = $l', logicArgs=(/mp_kessler_in/))
 call mpas_log_write('    mp_thompson_in          = $l', logicArgs=(/mp_thompson_in/))
 call mpas_log_write('    mp_wsm6_in              = $l', logicArgs=(/mp_wsm6_in/))

!--- initialization of all packages for parameterizations of convection:

 call mpas_pool_get_config(configs,'config_convection_scheme',config_convection_scheme)

 nullify(cu_grell_freitas_in)
 call mpas_pool_get_package(packages,'cu_grell_freitas_inActive',cu_grell_freitas_in)

 nullify(cu_kain_fritsch_in)
 call mpas_pool_get_package(packages,'cu_kain_fritsch_inActive',cu_kain_fritsch_in)

 nullify(cu_tiedtke_in)
 call mpas_pool_get_package(packages,'cu_tiedtke_inActive',cu_tiedtke_in)

 if(.not.associated(cu_grell_freitas_in) .or. &
    .not.associated(cu_kain_fritsch_in)  .or. &
    .not.associated(cu_tiedtke_in)     ) then
    call mpas_log_write('====================================================================================',messageType=MPAS_LOG_ERR)
    call mpas_log_write('* Error while setting up packages for convection options in atmosphere core.',        messageType=MPAS_LOG_ERR)
    call mpas_log_write('====================================================================================',messageType=MPAS_LOG_ERR)
    ierr = 1
    return
 endif

 cu_grell_freitas_in = .false.
 cu_kain_fritsch_in  = .false.
 cu_tiedtke_in       = .false.

 if(config_convection_scheme=='cu_grell_freitas') then
    cu_grell_freitas_in = .true.
 elseif(config_convection_scheme == 'cu_kain_fritsch') then
    cu_kain_fritsch_in = .true.
 elseif(config_convection_scheme == 'cu_tiedtke' .or. &
        config_convection_scheme == 'cu_ntiedtke') then
    cu_tiedtke_in = .true.
 endif

 call mpas_log_write('    cu_grell_freitas_in     = $l', logicArgs=(/cu_grell_freitas_in/))
 call mpas_log_write('    cu_kain_fritsch_in      = $l', logicArgs=(/cu_kain_fritsch_in/))
 call mpas_log_write('    cu_tiedtke_in           = $l', logicArgs=(/cu_tiedtke_in/))

!--- initialization of all packages for parameterizations of surface layer and planetary boundary layer:

 call mpas_pool_get_config(configs,'config_pbl_scheme',config_pbl_scheme)

 nullify(bl_mynn_in)
 call mpas_pool_get_package(packages,'bl_mynn_inActive',bl_mynn_in)

 nullify(bl_ysu_in)
 call mpas_pool_get_package(packages,'bl_ysu_inActive',bl_ysu_in)

 nullify(bl_acm_in)
 call mpas_pool_get_package(packages,'bl_acm_inActive',bl_acm_in)

 if(.not.associated(bl_mynn_in) .or. &
    .not.associated(bl_ysu_in)  .or. &
    .not.associated(bl_acm_in)) then
    call mpas_log_write('====================================================================================',messageType=MPAS_LOG_ERR)
    call mpas_log_write('* Error while setting up packages for planetary layer  options in atmosphere core.',  messageType=MPAS_LOG_ERR)
    call mpas_log_write('====================================================================================',messageType=MPAS_LOG_ERR)
    ierr = 1
    return
 endif

 bl_mynn_in = .false.
 bl_ysu_in  = .false.
 bl_acm_in  = .false.

 if(config_pbl_scheme=='bl_mynn') then
    bl_mynn_in = .true.
 elseif(config_pbl_scheme == 'bl_ysu') then
    bl_ysu_in = .true.
 elseif(config_pbl_scheme == 'bl_acm') then
    bl_acm_in = .true.
 endif

 call mpas_log_write('    bl_mynn_in              = $l', logicArgs=(/bl_mynn_in/))
 call mpas_log_write('    bl_ysu_in               = $l', logicArgs=(/bl_ysu_in/))
 call mpas_log_write('    bl_acm_in               = $l', logicArgs=(/bl_acm_in/))
 call mpas_log_write('')

 end function atmphys_setup_packages

!=================================================================================================================
 end module mpas_atmphys_packages
!=================================================================================================================



