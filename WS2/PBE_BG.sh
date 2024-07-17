#Script is written by Ahsan Javed to automate the VASP calculation.
#POSCAR and POTCAR file should be available in folders.
module load mpi/openmpi-x86_64

mkdir 1.relax
mkdir 2.dft
mkdir 3.band
cp POSCAR POTCAR 1.relax

cd 1.relax
 
cat > INCAR << EOF
#Relaxation
ISTART =  0
ENCUT  =  400
EDIFF  =  1E-6
ISMEAR =  0
NELM   =  200
SIGMA  = 0.05
IBRION =  2
ISIF   =  4

LASPH = .TRUE.
LCHARG = .FALSE.
LREAL = .FALSE.
LWAVE = .FALSE.
ADDGRID = .True.

NPAR = 9
KPAR = 5
EOF

#KPOINTS
cat > KPOINTS << EOF
K-Points
0
Gamma
  11   11   1
 0.0  0.0  0.0
EOF

mpirun -np 45 vasp_std

cp CONTCAR ../2.dft/POSCAR
cp KPOINTS POTCAR ../2.dft
cd ../2.dft

cat > INCAR << EOF
System = WS2 
ISTART = 0
ISMEAR = 0
SIGMA  = 0.05
EDIFF  = 1E-6
ICHARG =  2
ENCUT  = 400
NELM   = 200
PREC   = Accurate

LSORBIT       = .TRUE.
LNONCOLLINEAR = .TRUE.
LMAXMIX       =  4

NPAR   =  9
KPAR   =  5
EOF

mpirun -np 45 vasp_ncl

cp CHGCAR POSCAR POTCAR ../3.band
cd ../3.band

cat > INCAR << EOF
SYSTEM        = WS2
ISTART        =  0
ENCUT         = 400
EDIFF         = 1E-6
ISMEAR        = 0
SIGMA         = 0.05
ICHARG        = 11
NELM          = 300
LSORBIT       = .TRUE.
LNONCOLLINEAR = .TRUE.
LMAXMIX       = 4
NPAR          =  9
KPAR          =  5
PREC          = Accurate

LORBIT =  11           (PAW radii for projected DOS)
NEDOS  =  2001         (DOSCAR points)
EOF

vaspkit -task 302
mv KPATH.in KPOINTS
mpirun -np 45 vasp_ncl
