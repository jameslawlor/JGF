!Just the single integral (other performed by contour integration)
module shared_data
implicit none
  save
  ! Mathematical parameters
  complex(8), parameter :: im = (0.0d0,1.0d0)
  real(8), parameter :: pi = acos(-1.0d0)
  ! Material parameters
  real(8), parameter :: t = -1.0d0
end module


function gtest(m,n,s,E,E0,kZ)
use shared_data
implicit none
  ! Input arguments
  complex(8) :: gtest
  complex(8), intent(in) :: E
  real(8), intent(in) :: kZ
  real(8), intent(in) :: E0	! The onsite energy
  integer, intent(in) :: m,n
  integer, intent(in) :: s	! The sublattice term. 0 for bb, 1 for bw, -1 for wb.
  ! Dummy arguments
  complex(8) :: f, ft 
  complex(8) :: q
  complex(8) :: Const, Den
  integer :: sig

  q = acos( ((E-E0)**2 - t**2 - 4.0d0*t**2 *cos(kZ)**2)/(4.0d0*t**2 *cos(kZ) ) )

  if (aimag(q) < 0.0d0) q = -q

  Const = im/(4*pi*t**2)
  Den = cos(kZ)*sin(q)

  if (s == 0) then
    sig = sign(1,m+n)
    gtest = Const*(E-E0)*exp( im*(sig*q*(m+n) + kZ*(m-n) ) )/ Den 
  else if (s == 1) then 
    sig = sign(1,m+n)
    f = t*( 1.0d0 + 2.0d0*cos(kZ)*exp(sig*im*q) )
    gtest = Const*f*exp( im*(sig*q*(m+n) + kZ*(m-n) ) )/Den  
  else if (s == -1) then
    sig = sign(1,m+n-1)
    ft = t*( 1.0d0 + 2.0d0*cos(kZ)*exp(-sig*im*q) )
    gtest = Const*ft*exp( im*(sig*q*(m+n) + kZ*(m-n) ) )/Den 
  else
    print *, "Sublattice error in gtest"
  end if
    
end function gtest 


function gbulk_kz_int(m,n,s,E,kZ)
use shared_data
implicit none
  ! Input arguments
  complex(8) :: gbulk_kz_int
  complex(8), intent(in) :: E
  real(8), intent(in) :: kZ
  integer, intent(in) :: m,n
  integer, intent(in) :: s	! The sublattice term. 0 for bb, 1 for bw, -1 for wb.
  ! Dummy arguments
  complex(8) :: f, ft 
  complex(8) :: q
  complex(8) :: Const, Den
  integer :: sig

  q = acos( (E**2 - t**2 - 4.0d0*t**2 *cos(kZ)**2)/(4.0d0*t**2 *cos(kZ) ) )

  if (aimag(q) < 0.0d0) q = -q

  Const = im/(4*pi*t**2)
  Den = cos(kZ)*sin(q)

  if (s == 0) then
    sig = sign(1,m+n)
    gbulk_kz_int = Const*E*exp( im*(sig*q*(m+n) + kZ*(m-n) ) )/ Den 
  else if (s == 1) then 
    sig = sign(1,m+n)
    f = t*( 1.0d0 + 2.0d0*cos(kZ)*exp(sig*im*q) )
    gbulk_kz_int = Const*f*exp( im*(sig*q*(m+n) + kZ*(m-n) ) )/Den  
  else if (s == -1) then
    sig = sign(1,m+n-1)
    ft = t*( 1.0d0 + 2.0d0*cos(kZ)*exp(-sig*im*q) )
    gbulk_kz_int = Const*ft*exp( im*(sig*q*(m+n) + kZ*(m-n) ) )/Den 
  else
    print *, "Sublattice error in gbulk_kz_int"
  end if
  
end function gbulk_kz_int 


function grib_arm(nE,m1,n1,m2,n2,s,E)
use shared_data
implicit none
  complex(8) :: grib_arm
  integer :: j
  ! Other parameters
  complex(8) :: E
  integer :: m1, n1, m2, n2, s
  integer :: nE
  
  grib_arm = 0.0d0
  if ( mod(nE,2) .eq. 0 ) then
    do j = 1, nE-1
      if ( j .eq. nE/2 ) cycle		! Avoid singularities
      grib_arm = grib_arm + g_term(pi*j/nE)
    end do
    if ( m2+n2-m1-n1 .eq. 0 ) then
      grib_arm = grib_arm + limit_term(pi/2)
    end if
  else 
    do j = 1, nE-1
      grib_arm = grib_arm + g_term(pi*j/nE)
    end do
  end if

  contains

    function g_term (ky)
    implicit none
      complex(8) :: g_term
      real(8), intent(in) :: ky

      complex(8) :: f, ft 
      complex(8) :: q
      complex(8) :: Const, Den
      integer :: sig

      q = acos( (E**2 - t**2 - 4.0d0*t**2 *cos(ky)**2)/(4.0d0*t**2 *cos(ky) ) )
      if (aimag(q) < 0.0d0) q = -q

      Const = im/(2.0d0*nE*t**2)
      Den = cos(ky)*sin(q)

      if (s == 0) then
	sig = sign(1,m2+n2-m1-n1)
	g_term = Const*E*exp( im*sig*q*(m2+n2-m1-n1) )*sin(ky*(m2-n2))*sin(ky*(m1-n1))/ Den 
      else if (s == 1) then 
	sig = sign(1,m2+n2-m1-n1)
	f = 1.0d0 + 2.0d0*cos(ky)*exp(sig*im*q)
	g_term = Const*t*f*exp( im*sig*q*(m2+n2-m1-n1) )*sin(ky*(m2-n2))*sin(ky*(m1-n1))/ Den 
      else if (s == -1) then
	sig = sign(1,m2+n2-m1-n1-1)
	ft = 1.0d0 + 2.0d0*cos(ky)*exp(-sig*im*q)
	g_term = Const*t*ft*exp( im*sig*q*(m2+n2-m1-n1) )*sin(ky*(m2-n2))*sin(ky*(m1-n1))/ Den 
      else
	write(*,*) 'Sublattice error in grib_arm'
      end if

    end function g_term 
    
    function limit_term (ky)
    implicit none
      complex(8) :: limit_term
      real(8), intent(in) :: ky
      complex(8) :: N_ab

      if (s == 0) then
	N_ab = E
      else if ( (s == 1) .or. (s == -1) ) then
	N_ab = t
      else
	write(*,*) 'Sublattice error in grib_arm'
      end if
      
      limit_term = 2.0d0*N_ab*sin(ky*(m2-n2))*sin(ky*(m1-n1))/( nE*( E**2 - t**2 ) )

    end function limit_term 

end function grib_arm


function gtube_arm(nC,m,n,s,E)
use shared_data
implicit none
  ! Calculates the GF for an armchair nanotube
  ! Input arguments
  complex(8) :: gtube_arm
  complex(8), intent(in) :: E
  integer, intent(in) :: m,n,s
  integer, intent(in) :: nC
  ! Dummy arguments
  complex(8) :: qp, qm
  complex(8) :: const
  complex(8) :: fm, fp, ftm, ftp
  integer :: k
  integer :: sig
  
  gtube_arm = 0.0d0    
  do k = 0, nC-1	! possible

    qp = acos( 0.5d0*(-cos(pi*k/nC) + sqrt( (E**2/t**2) - (sin(pi*k/nC))**2 ) )  )
    qm = acos( 0.5d0*(-cos(pi*k/nC) - sqrt( (E**2/t**2) - (sin(pi*k/nC))**2 ) )  ) 

    if (aimag(qp) < 0.0) qp = -qp
    if (aimag(qm) < 0.0) qm = -qm

    sig = sign(1,m-n)		! Really fucking hope this is correct. Doesn't really match up with the other ones
    const = im/(4.0d0*t**2)
    if (s == 0) then
      gtube_arm = gtube_arm + const*( E*exp( im*( pi*k/nC *(m+n) + sig*qp*(m-n) )  ) / ( sin(2.0d0*qp) + sin(qp)*cos(pi*k/nC)  ) &
	+ E*exp( im*(  pi*k/nC *(m+n) + sig*qm*(m-n) )  ) / ( sin(2.0d0*qm) + sin(qm)*cos(pi*k/nC)  )  ) 
    else if (s == 1) then
      fp = t*( 1.0d0 + 2.0d0*cos(qp)*exp(im*pi*k/nC)  )
      fm = t*( 1.0d0 + 2.0d0*cos(qm)*exp(im*pi*k/nC)  )

      gtube_arm = gtube_arm + const*( fp*exp( im*( pi*k/nC *(m+n) + sig*qp*(m-n) )  ) / ( sin(2.0d0*qp) + sin(qp)*cos(pi*k/nC)  ) &
      + fm*exp( im*( pi*k/nC *(m+n) + sig*qm*(m-n) )  ) / ( sin(2.0d0*qm) + sin(qm)*cos(pi*k/nC)  )  ) 
    else if (s == -1) then
      ftp = t*( 1.0d0 + 2.0d0*cos(qp)*exp(-im*pi*k/nC)  )
      ftm = t*( 1.0d0 + 2.0d0*cos(qm)*exp(-im*pi*k/nC)  )

      gtube_arm = gtube_arm + const*( exp( im*( pi*k/nC *(m+n) + sig*qp*(m-n) )  )*ftp / ( sin(2.0d0*qp) + sin(qp)*cos(pi*k/nC)  ) &
      + exp( im*( pi*k/nC *(m+n) + sig*qm*(m-n) )  )*ftm / ( sin(2.0d0*qm) + sin(qm)*cos(pi*k/nC)  )  ) 
    else
      print *, "Sublattice error in gTube_Arm"
    end if
  end do
  
  gtube_arm = gtube_arm/nC
    
end function gtube_arm