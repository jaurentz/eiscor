#include "eiscor.h"
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
! z_uprkfact_buildbulge
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
! This routine computes the first transformation for a sinlge shift
! iteration on a uprk pencil.
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
!
! INPUT VARIABLES:
!
!  QZ             LOGICAL
!                    .TRUE.: second triangular factor is assumed nonzero
!                    .FALSE.: second triangular factor is assumed to be identity
!
!  N               INTEGER
!                    dimension of matrix
!
!  K               INTEGER
!                    number of triangulars/rank
!
!  ROW             INTEGER
!                    first row of 2x2 block, it is assumed that in case
!                    of TOP that there is no Q-rotation above
!                    and in case of not TOP that there is no Q-rotation below
!
!  P               LOGICAL 
!                    position flag for Q
!
!  Q               REAL(8) array of dimension (6)
!                    array of generators for first sequence of rotations
!
!  D1,D2           REAL(8) arrays of dimension (4)
!                    array of generators for complex diagonal matrices
!                    in the upper-triangular factors
!                    If QZ == .FALSE., D2 is unused.
!
!  C1,B1,C2,B2     REAL(8) arrays of dimension (6)
!                    array of generators for upper-triangular parts
!                    of the pencil
!                    If QZ == .FALSE., C2 and B2 are unused.
!
!  SHFT            COMPLEX(8) 
!                    contains the shift needed for the first transformation
!
! OUTPUT VARIABLES:
!
!  G               REAL(8) array of dimension (3)
!                    on exit contains the generators for the first
!                    transformation
!
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
subroutine z_uprkfact_buildbulge(QZ,N,K,ROW,P,Q,D1,C1,B1,D2,C2,B2,SHFT,G)
  
  implicit none
  
  ! input variables
  logical, intent(in) :: QZ, P(N-2)
  integer, intent(in) :: N, K, ROW
  real(8), intent(inout) :: Q(3*K*(N-1)), D1(2*K*(N+1)), C1(3*K*N), B1(3*K*N)
  real(8), intent(inout) :: D2(2*K*(N+1)), C2(3*K*N), B2(3*K*N)
  complex(8), intent(in) :: SHFT
  real(8), intent(inout) :: G(3)

  ! compute variables
  real(8) :: nrm
  complex(8) :: A(2,2), B(2,2), vec1(2), vec2(2)
  

  ! get 2x2 blocks
  call z_uprkfact_2x2diagblocks(.TRUE.,.FALSE.,QZ,N,K,ROW,P,Q,D1,C1,B1,D2,C2,B2,A,B)
     
  ! set B to I of not QZ
  if (.NOT.QZ) then
    B = cmplx(0d0,0d0,kind=8)
    B(1,1) = cmplx(1d0,0d0,kind=8); B(2,2) = B(1,1)
  end if

  ! compute first columns
  ! P == FALSE
  if (.NOT.P(ROW)) then
   
    ! first column of A
    vec1(1) = cmplx(Q(3*ROW-2),Q(3*ROW-1),kind=8)*A(1,1)
    vec1(2) = cmplx(Q(3*ROW),0d0,kind=8)*A(1,1)
    
    ! first column of B
    vec2(1) = B(1,1)
    vec2(2) = B(2,1)
  
  ! P == TRUE
  else
    
    ! Q*e1
    vec2(1) = cmplx(Q(3*ROW-2),-Q(3*ROW-1),kind=8)
    vec2(2) = cmplx(-Q(3*ROW),0d0,kind=8)
    
    ! back solve with A
    vec2(2) = vec2(2)/A(2,2)
    vec2(1) = (vec2(1) - A(1,2)*vec2(2))/A(1,1)
    
    ! B^-1 e1
    vec1(1) = 1d0/B(1,1)
    vec1(2) = 0d0
  
  end if
  
  ! insert shift
  vec1 = vec1 - SHFT*vec2
  
  ! compute eliminator
  call z_rot3_vec4gen(dble(vec1(1)),aimag(vec1(1)),dble(vec1(2)),aimag(vec1(2)),G(1),G(2),G(3),nrm)
      
end subroutine z_uprkfact_buildbulge
