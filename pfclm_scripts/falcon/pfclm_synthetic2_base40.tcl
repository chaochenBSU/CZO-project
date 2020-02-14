# SCRIPT TO RUN LITTLE WASHITA DOMAIN WITH TERRAIN-FOLLOWING GRID
# DETAILS:
# -- UNIFORM MET FORCING (narr_1hr.txt)
# -- top dm has different soil properties, DZ=2m 
# -- SPATIALLY DISTRIBUTED SOILS @ TOP LAYER, UNIFORM BELOW
# -- 30M SUBSURFACE
# -- DEFAULT CLM IC (defined, not restart)
# -- Initial Pressure use initial_pressure.pfb file


# Import the ParFlow TCL package
lappend   auto_path $env(PARFLOW_DIR)/bin
package   require parflow
namespace import Parflow::*

pfset     FileVersion    4

#-----------------------------------------------------------------------------
# Set up run outputs
#-----------------------------------------------------------------------------
exec mkdir "../outputs_pfclm2_base40"
cd "../outputs_pfclm2_base40"

# path to clm_input
set clmdir      "../clm_input"
# set water_balance_script "/home/cchen/scratch/parflow/RME_200mthick_40_1soil_3D/pf_scripts_clm/WaterBalance_cal.tcl"


# ----------------------------------------------------------------------------
# Set up run input file names
# ----------------------------------------------------------------------------
# Files:
# initial condition file from last drainage output 
set ip0      "../initialcond/pf2_base40.out.press.00045.pfb"
# slope files
set sx      "WS2_SR.sx.pfb"
set sy      "WS2_SR.sy.pfb"
# soil indicator file
set si      "Soil_indi_WS2_base.indi.pfb"

# clm input files
# set metfile "NLDAS"
set meteo    "narr_1hr_new_extended.txt"
set vegf     "drv_vegp.dat"
set clmin    "drv_clmin.dat"
set vegalu   "drv_vegm.alluv.dat"

#-----------------------------------------------------------------------------
# Copy input files to run directory
# ----------------------------------------------------------------------------
# ParFlow Input
file copy -force ../parflow_input/WS2_SR.sx.pfb .
file copy -force ../parflow_input/WS2_SR.sy.pfb .
file copy -force ../parflow_input/geo_indi/Soil_indi_WS2_base.indi.pfb .
# CLM Input
file copy -force ../clm_input/drv_vegp.dat          .
file copy -force ../clm_input/narr_1hr_new_extended.txt          .
file copy -force ../clm_input/drv_clmin.dat         .
file copy -force ../clm_input/drv_vegm.alluv.dat    .


#-----------------------------------------------------------------------------
# Set up run info
#-----------------------------------------------------------------------------
set runname                               "pfclm2_base40"
set rundir                                .

set startcount                            0.0
set starttime                             0.0
set stoptime                              336
set istep                                 1
set tstep                                 0.01
set dmpinterval                           1
set rc                                    100
  
set nx                                    198 
set ny                                    198
set nz                                    16 

set dx                                    30.0
set dy                                    30.0
set dz                                    5.0

set x0                                    0.0
set y0                                    0.0
set z0                                    -80.0


#-----------------------------------------------------------------------------
# Processor topology (P=x-direction,Q=y-direction,R=z-direction)
#-----------------------------------------------------------------------------
pfset Process.Topology.P                 8 
pfset Process.Topology.Q                  14
pfset Process.Topology.R                  1


#-----------------------------------------------------------------------------
# Computational Grid
#-----------------------------------------------------------------------------
pfset ComputationalGrid.Lower.X           $x0
pfset ComputationalGrid.Lower.Y           $y0
pfset ComputationalGrid.Lower.Z           $z0 

pfset ComputationalGrid.NX                $nx 
pfset ComputationalGrid.NY                $ny 
pfset ComputationalGrid.NZ                $nz 

pfset ComputationalGrid.DX                $dx
pfset ComputationalGrid.DY                $dy
pfset ComputationalGrid.DZ                $dz

#-----------------------------------------------------------------------------
# Soil paramameters (Van Genuchten)
#-----------------------------------------------------------------------------

# ---------- Bed Rock (BR) ----------

set Perm_val_BR				  0.000001			
set Poros_val_BR			  0.0004

set RPerm_alpha_BR			  3.5
set RPerm_n_BR				  2.0
set S_alpha_BR				  3.5
set S_n_BR				      2.0

set S_sres_BR				  0.126
#set S_sres_BR				  0.000001
set S_ssat_BR				  1.0

# ---------- Fractured Bed Rock (FracBR) ----------

set Perm_val_FracBR				  0.000001			
set Poros_val_FracBR			  0.0004

set RPerm_alpha_FracBR			  3.5
set RPerm_n_FracBR				  2.0
set S_alpha_FracBR				  3.5
set S_n_FracBR				      2.0

set S_sres_FracBR				  0.126
#set S_sres_FracBR				  0.000001
set S_ssat_FracBR				  1.0

# ---------- Saprolite (Sapro) ----------

set Perm_val_Sapro				  0.01			
set Poros_val_Sapro			  0.2

set RPerm_alpha_Sapro			  3.5
set RPerm_n_Sapro				  2.0
set S_alpha_Sapro				  3.5
set S_n_Sapro				      2.0

set S_sres_Sapro				  0.126
#set S_sres_Sapro				  0.000001
set S_ssat_Sapro				  1.0

# ---------- Loamy sand (LS) ----------
set Perm_val_LS				  0.1459			
set Poros_val_LS			  0.41

set RPerm_alpha_LS			  12.4
set RPerm_n_LS				  2.28
set S_alpha_LS				  12.4
set S_n_LS				      2.28

#set S_sres_LS                             0.000001
set S_sres_LS				  0.057
set S_ssat_LS				  1.0
			
# ---------- Sandy loam (SL) ----------
set Perm_val_SL				  0.0442	
set Poros_val_SL			  0.41

set RPerm_alpha_SL			  7.5
set RPerm_n_SL			   	  1.89
set S_alpha_SL				  7.5
set S_n_SL				      1.89

#set S_sres_SL                             0.000001
set S_sres_SL				  0.065
set S_ssat_SL				  1.0		
	
# ---------- Sandy clay loam (SCL) ----------
# set Perm_val_SCL			  0.0131	
# set Poros_val_SCL			  0.39

# set RPerm_alpha_SCL			  5.9
# set RPerm_n_SCL			   	  1.48
# set S_alpha_SCL				  5.9
# set S_n_SCL				      1.48

# set S_sres_SCL                            0.1
# #set S_sres_SCL				  0.000001
# set S_ssat_SCL				  1.0		

# ---------- Sandy clay loam (SCL) ----------assumptive, values are same as Loam
set Perm_val_SCL			  0.0104	
set Poros_val_SCL			  0.43

set RPerm_alpha_SCL			  3.6
set RPerm_n_SCL			   	  1.56
set S_alpha_SCL				  3.6
set S_n_SCL				      1.56

set S_sres_SCL                0.1
#set S_sres_SCL				  0.000001
set S_ssat_SCL				  1.0	

# ---------- Loam (L) ----------
set Perm_val_L				  0.0104	
set Poros_val_L			  	  0.43

set RPerm_alpha_L			  3.6
set RPerm_n_L			   	  1.56
set S_alpha_L				  3.6
set S_n_L				      1.56

set S_sres_L                  0.078
#set S_sres_L				  0.000001
set S_ssat_L				  1.0

# ---------- Clay (C) ----------
set Perm_val_C				  0.0104
set Poros_val_C			  	  0.43

set RPerm_alpha_C			  3.6
set RPerm_n_C			   	  1.56
set S_alpha_C				  3.6
set S_n_C			     	  1.56

set S_sres_C                  0.068
#set S_sres_C				  0.000001
set S_ssat_C				  1.0

# ---------- Clay (C) ----------
# set Perm_val_C                            0.002
# set Poros_val_C                           0.38
#
# set RPerm_alpha_C                         0.8
# set RPerm_n_C                             1.09
# set S_alpha_C                             0.8
# set S_n_C                                 1.09
#
# #set S_sres_C                              0.068
# set S_sres_C                              0.000001
# set S_ssat_C                              1.0
#


#--------------------------------------------
# variable dz assignments
#------------------------------------------
pfset Solver.Nonlinear.VariableDz       True
pfset dzScale.GeomNames                 domain
pfset dzScale.Type                      nzList
pfset dzScale.nzListNumber              16

pfset	Cell.0.dzScale.Value	2.0000
pfset	Cell.1.dzScale.Value	1.8232
pfset	Cell.2.dzScale.Value	0.9116
pfset	Cell.3.dzScale.Value	0.9116
pfset	Cell.4.dzScale.Value	0.6837
pfset	Cell.5.dzScale.Value	0.2279
pfset	Cell.6.dzScale.Value	0.0182
pfset	Cell.7.dzScale.Value	0.0137
pfset	Cell.8.dzScale.Value	0.0137
pfset	Cell.9.dzScale.Value	0.0137
pfset	Cell.10.dzScale.Value	0.0137
pfset	Cell.11.dzScale.Value	0.0137
pfset	Cell.12.dzScale.Value	0.0114
pfset	Cell.13.dzScale.Value	0.0091
pfset	Cell.14.dzScale.Value	0.0046
pfset	Cell.15.dzScale.Value	0.0023


#-----------------------------------------------------------------------------
# Timing (time units is set by units of permeability)
#-----------------------------------------------------------------------------
pfset TimingInfo.BaseUnit                 1.0
pfset TimingInfo.StartCount               $startcount
pfset TimingInfo.StartTime                $starttime
pfset TimingInfo.StopTime                 $stoptime
pfset TimingInfo.DumpInterval             $dmpinterval
pfset TimeStep.Type                       Constant
pfset TimeStep.Value                      $tstep


#-----------------------------------------------------------------------------
# Domain
#-----------------------------------------------------------------------------
pfset Domain.GeomName                     "domain"


#-----------------------------------------------------------------------------
# Names of the GeomInputs
#-----------------------------------------------------------------------------
pfset GeomInput.Names                     "box_input indi_input"


#-----------------------------------------------------------------------------
# SolidFile Geometry Input
#-----------------------------------------------------------------------------
pfset GeomInput.box_input.InputType      Box
pfset GeomInput.box_input.GeomName      "domain"


#---------------------------------------------------------
# Domain Geometry 
#---------------------------------------------------------
pfset Geom.domain.Lower.X                        $x0
pfset Geom.domain.Lower.Y                        $y0
pfset Geom.domain.Lower.Z                        $z0
 
pfset Geom.domain.Upper.X                        5940.0
pfset Geom.domain.Upper.Y                        5940.0
pfset Geom.domain.Upper.Z                        0.0
# pfset Geom.domain.Patches             "left right front back bottom top"
pfset Geom.domain.Patches             "x-lower x-upper y-lower y-upper z-lower z-upper"


#-----------------------------------------------------------------------------
# Indicator Geometry Input
#-----------------------------------------------------------------------------
pfset GeomInput.indi_input.InputType      IndicatorField
pfset GeomInput.indi_input.GeomNames      "F1 F1S F2"
pfset Geom.indi_input.FileName            $si

pfset GeomInput.F1.Value	      3

pfset GeomInput.F1S.Value	      2

pfset GeomInput.F2.Value		  1




#-----------------------------------------------------------------------------
# Permeability (values in m/hr)
#-----------------------------------------------------------------------------
pfset Geom.Perm.Names                     "domain F1 F1S F2"
pfset Geom.Perm.Names                     "domain"

pfset Geom.domain.Perm.Type               Constant
pfset Geom.domain.Perm.Value              $Perm_val_LS

pfset Geom.F1.Perm.Type                   Constant
pfset Geom.F1.Perm.Value                  $Perm_val_BR

# pfset Geom.F1F.Perm.Type                   Constant
# pfset Geom.F1F.Perm.Value                  $Perm_val_FracBR

pfset Geom.F1S.Perm.Type                   Constant
pfset Geom.F1S.Perm.Value                  $Perm_val_Sapro

pfset Geom.F2.Perm.Type                   Constant
pfset Geom.F2.Perm.Value                  $Perm_val_SCL

#pfset Geom.F3.Perm.Type                   Constant
#pfset Geom.F3.Perm.Value                  $Perm_val_L

#-----------------------------------------------------------------------------
# Permeability Tensors
#-----------------------------------------------------------------------------
pfset Perm.TensorType                     TensorByGeom
pfset Geom.Perm.TensorByGeom.Names        "domain"
pfset Geom.domain.Perm.TensorValX         1.0d0
pfset Geom.domain.Perm.TensorValY         1.0d0
pfset Geom.domain.Perm.TensorValZ         1.0d0


#-----------------------------------------------------------------------------
# Specific Storage
#-----------------------------------------------------------------------------
pfset SpecificStorage.Type                Constant
pfset SpecificStorage.GeomNames           "domain"
pfset Geom.domain.SpecificStorage.Value   1.0e-4


#-----------------------------------------------------------------------------
# Phases
#-----------------------------------------------------------------------------
pfset Phase.Names                         "water"
pfset Phase.water.Density.Type            Constant
pfset Phase.water.Density.Value           1.0
pfset Phase.water.Viscosity.Type          Constant
pfset Phase.water.Viscosity.Value         1.0


#-----------------------------------------------------------------------------
# Contaminants
#-----------------------------------------------------------------------------
pfset Contaminants.Names                  ""


#-----------------------------------------------------------------------------
# Retardation
#-----------------------------------------------------------------------------
pfset Geom.Retardation.GeomNames          ""


#-----------------------------------------------------------------------------
# Gravity
#-----------------------------------------------------------------------------
pfset Gravity                             1.0


#-----------------------------------------------------------------------------
# Porosity
#-----------------------------------------------------------------------------
pfset Geom.Porosity.GeomNames             "domain F1 F1S F2"

pfset Geom.domain.Porosity.Type           Constant
pfset Geom.domain.Porosity.Value          $Poros_val_LS

pfset Geom.F1.Porosity.Type               Constant
pfset Geom.F1.Porosity.Value              $Poros_val_BR

# pfset Geom.F1F.Porosity.Type               Constant
# pfset Geom.F1F.Porosity.Value              $Poros_val_FracBR

pfset Geom.F1S.Porosity.Type               Constant
pfset Geom.F1S.Porosity.Value              $Poros_val_Sapro

pfset Geom.F2.Porosity.Type               Constant
pfset Geom.F2.Porosity.Value              $Poros_val_SCL

# pfset Geom.F3.Porosity.Type               Constant
# pfset Geom.F3.Porosity.Value              $Poros_val_L


#-----------------------------------------------------------------------------
# Relative Permeability
#-----------------------------------------------------------------------------
pfset Phase.RelPerm.Type                  VanGenuchten
pfset Phase.RelPerm.GeomNames             "domain F1 F1S F2"

pfset Geom.domain.RelPerm.Alpha       $RPerm_alpha_LS
pfset Geom.domain.RelPerm.N           $RPerm_n_LS

# Relative Permeability input values
pfset Geom.F1.RelPerm.Alpha    $RPerm_alpha_BR
pfset Geom.F1.RelPerm.N        $RPerm_n_BR
# pfset Geom.F1F.RelPerm.Alpha    $RPerm_alpha_FracBR
# pfset Geom.F1F.RelPerm.N        $RPerm_n_FracBR
pfset Geom.F1S.RelPerm.Alpha    $RPerm_alpha_Sapro
pfset Geom.F1S.RelPerm.N        $RPerm_n_Sapro
pfset Geom.F2.RelPerm.Alpha    $RPerm_alpha_SCL
pfset Geom.F2.RelPerm.N        $RPerm_n_SCL
# pfset Geom.F3.RelPerm.Alpha    $RPerm_alpha_L
# pfset Geom.F3.RelPerm.N        $RPerm_n_L

#-----------------------------------------------------------------------------
# Saturation
#-----------------------------------------------------------------------------
pfset Phase.Saturation.Type               VanGenuchten
pfset Phase.Saturation.GeomNames          "domain F1 F1S F2"

pfset Geom.domain.Saturation.Alpha       $S_alpha_LS
pfset Geom.domain.Saturation.N           $S_n_LS
pfset Geom.domain.Saturation.SRes        $S_sres_LS
pfset Geom.domain.Saturation.SSat        $S_ssat_LS

# Saturation input values
pfset Geom.F1.Saturation.Alpha    $S_alpha_BR
pfset Geom.F1.Saturation.N        $S_n_BR
pfset Geom.F1.Saturation.SRes     $S_sres_BR
pfset Geom.F1.Saturation.SSat     $S_ssat_BR

# pfset Geom.F1F.Saturation.Alpha    $S_alpha_FracBR
# pfset Geom.F1F.Saturation.N        $S_n_FracBR
# pfset Geom.F1F.Saturation.SRes     $S_sres_FracBR
# pfset Geom.F1F.Saturation.SSat     $S_ssat_FracBR

pfset Geom.F1S.Saturation.Alpha    $S_alpha_Sapro
pfset Geom.F1S.Saturation.N        $S_n_Sapro
pfset Geom.F1S.Saturation.SRes     $S_sres_Sapro
pfset Geom.F1S.Saturation.SSat     $S_ssat_Sapro

pfset Geom.F2.Saturation.Alpha    $S_alpha_SCL
pfset Geom.F2.Saturation.N        $S_n_SCL
pfset Geom.F2.Saturation.SRes     $S_sres_SCL
pfset Geom.F2.Saturation.SSat     $S_ssat_SCL
# pfset Geom.F3.Saturation.Alpha    $S_alpha_L
# pfset Geom.F3.Saturation.N        $S_n_L
# pfset Geom.F3.Saturation.SRes     $S_sres_L
# pfset Geom.F3.Saturation.SSat     $S_ssat_L



#-----------------------------------------------------------------------------
# Wells
#-----------------------------------------------------------------------------
pfset Wells.Names                         ""


#-----------------------------------------------------------------------------
# Time Cycles
#-----------------------------------------------------------------------------
pfset Cycle.Names                         "constant"
pfset Cycle.constant.Names                "alltime"
pfset Cycle.constant.alltime.Length        1
pfset Cycle.constant.Repeat               -1


#-----------------------------------------------------------------------------
# Boundary Conditions: Pressure
#-----------------------------------------------------------------------------
pfset BCPressure.PatchNames                   [pfget Geom.domain.Patches]

pfset Patch.x-lower.BCPressure.Type		      FluxConst
pfset Patch.x-lower.BCPressure.Cycle		      "constant"
pfset Patch.x-lower.BCPressure.alltime.Value	      0.0

pfset Patch.y-lower.BCPressure.Type		      FluxConst
pfset Patch.y-lower.BCPressure.Cycle		      "constant"
pfset Patch.y-lower.BCPressure.alltime.Value	      0.0

pfset Patch.z-lower.BCPressure.Type		      FluxConst
pfset Patch.z-lower.BCPressure.Cycle		      "constant"
pfset Patch.z-lower.BCPressure.alltime.Value	      0.0

pfset Patch.x-upper.BCPressure.Type		      FluxConst
pfset Patch.x-upper.BCPressure.Cycle		      "constant"
pfset Patch.x-upper.BCPressure.alltime.Value	      0.0

pfset Patch.y-upper.BCPressure.Type		      FluxConst
pfset Patch.y-upper.BCPressure.Cycle		      "constant"
pfset Patch.y-upper.BCPressure.alltime.Value	      0.0

pfset Patch.z-upper.BCPressure.Type		      OverlandFlow
pfset Patch.z-upper.BCPressure.Cycle		      "constant"
pfset Patch.z-upper.BCPressure.alltime.Value	      0.0


#-----------------------------------------------------------------------------
# Topo slopes in x-direction
# pfsetgrid {nx ny nz} {x0 y0 z0} {dx dy dz} dataset
#-----------------------------------------------------------------------------

pfset TopoSlopesX.Type                                "PFBFile"
pfset TopoSlopesX.GeomNames                           "domain"
pfset TopoSlopesX.FileName                            $sx


#-----------------------------------------------------------------------------
# Topo slopes in y-direction
#-----------------------------------------------------------------------------

pfset TopoSlopesY.Type                                "PFBFile"
pfset TopoSlopesY.GeomNames                           "domain"
pfset TopoSlopesY.FileName                            $sy


#-----------------------------------------------------------------------------
# Mannings coefficient
#-----------------------------------------------------------------------------
pfset Mannings.Type                                   "Constant"
pfset Mannings.GeomNames                              "domain"
pfset Mannings.Geom.domain.Value                      5.52e-6
# set n 5.52e-6


#-----------------------------------------------------------------------------
# Phase sources:
#-----------------------------------------------------------------------------
pfset PhaseSources.water.Type                         "Constant"
pfset PhaseSources.water.GeomNames                    "domain"
pfset PhaseSources.water.Geom.domain.Value            0.0


#-----------------------------------------------------------------------------
# Exact solution specification for error calculations
#-----------------------------------------------------------------------------
pfset KnownSolution                                   NoKnownSolution


# # Turn off the lateral flow (spin-up process)
# pfset OverlandFlowSpinUp              1
# pfset OverlandSpinupDampP1			  10.0
# pfset OverlandSpinupDampP2			  0.1

#-----------------------------------------------------------------------------
# Set solver parameters
#-----------------------------------------------------------------------------
# ParFlow Solution
pfset Solver                                          Richards
pfset Solver.TerrainFollowingGrid                     True
pfset Solver.Nonlinear.VariableDz                     True

pfset Solver.MaxIter                                  50000000
pfset Solver.Drop                                     1E-20
pfset Solver.AbsTol                                   1E-8
pfset Solver.MaxConvergenceFailures                   8
pfset Solver.Nonlinear.MaxIter                        80
pfset Solver.Nonlinear.ResidualTol                    1e-6

## new solver settings for Terrain Following Grid

pfset Solver.Nonlinear.EtaChoice                         EtaConstant
pfset Solver.Nonlinear.EtaValue                          0.001
pfset Solver.Nonlinear.UseJacobian                       True 
pfset Solver.Nonlinear.DerivativeEpsilon                 1e-16
pfset Solver.Nonlinear.StepTol		                     1e-30
pfset Solver.Nonlinear.Globalization                     LineSearch
pfset Solver.Linear.KrylovDimension                      70
pfset Solver.Linear.MaxRestarts                           2

pfset Solver.Linear.Preconditioner                       PFMG
pfset Solver.Linear.Preconditioner.PCMatrixType     FullJacobian


# CLM:
pfset Solver.LSM                                      CLM
pfset Solver.CLM.CLMFileDir                           "./clm_output"
pfset Solver.CLM.Print1dOut                           False
pfset Solver.BinaryOutDir                             False
pfset Solver.CLM.CLMDumpInterval                      $dmpinterval

pfset Solver.CLM.EvapBeta                             Linear
pfset Solver.CLM.VegWaterStress                       Pressure
pfset Solver.CLM.ResSat                               0.1
pfset Solver.CLM.WiltingPoint                         0.12
pfset Solver.CLM.FieldCapacity                        0.98
pfset Solver.CLM.IrrigationType                       none

pfset Solver.CLM.MetForcing                           1D
pfset Solver.CLM.MetFileName                          $meteo
pfset Solver.CLM.MetFilePath                          $clmdir
pfset Solver.CLM.IstepStart                           $istep
# # # pfset Solver.CLM.MetForcing                           2D
# # # pfset Solver.CLM.MetFileName                          $metfile
# # # pfset Solver.CLM.MetFilePath                          $clmdir
# # # #pfset Solver.CLM.MetFileNT                            1
# # # pfset Solver.CLM.IstepStart                           $istep
pfset Solver.CLM.ReuseCount                           $rc

#Writing output (no binary except Pressure, all silo):
pfset Solver.PrintSubsurfData                         True
pfset Solver.PrintPressure                            True
pfset Solver.PrintSaturation                          True
pfset Solver.WriteCLMBinary                           False

pfset Solver.WriteSiloSpecificStorage                 False
pfset Solver.PrintCLM                                 True
pfset Solver.WriteSiloMannings                        False
pfset Solver.WriteSiloMask                            False
pfset Solver.WriteSiloSlopes                          True
pfset Solver.WriteSiloSubsurfData                     True
pfset Solver.WriteSiloPressure                        True
pfset Solver.WriteSiloSaturation                      True
pfset Solver.WriteSiloEvapTrans                       True
pfset Solver.WriteSiloEvapTransSum                    True
pfset Solver.WriteSiloOverlandSum                     True
pfset Solver.WriteSiloCLM                             True


#---------------------------------------------------------
# Initial conditions: water pressure
#---------------------------------------------------------
# pfset ICPressure.Type                                 HydroStaticPatch
# pfset ICPressure.GeomNames                            domain
# pfset Geom.domain.ICPressure.Value                    -0.7
# pfset Geom.domain.ICPressure.RefGeom                  domain
# pfset Geom.domain.ICPressure.RefPatch                 z-upper


#---------------------------------------------------------
# Initial conditions: water pressure hydrostatic
#---------------------------------------------------------
pfset ICPressure.Type                                 PFBFile
pfset ICPressure.GeomNames                            "domain"
pfset Geom.domain.ICPressure.FileName                    $ip0
pfset Geom.domain.ICPressure.RefGeom                  domain
pfset Geom.domain.ICPressure.RefPatch                 z-upper


#-----------------------------------------------------------------------------
# Run test
# If you don't include computational grid settings (NX, NY, NZ), 
# the file will be read for 1 layer at the bottom (k=0).
# To use a PFB file as the initial conditions, 
# distribute the file before executing the pfrun command.
#-----------------------------------------------------------------------------

puts " "
puts "Distributing input files..."

pfset ComputationalGrid.NX                $nx 
pfset ComputationalGrid.NY                $ny 
pfset ComputationalGrid.NZ                1
pfdist $sx
pfdist $sy
# distribute clm files

pfset ComputationalGrid.NX                $nx 
pfset ComputationalGrid.NY                $ny 
pfset ComputationalGrid.NZ                $nz 
pfdist $si
pfdist $ip0



puts " "
puts "Executing pfrun..."


pfrun    $runname

#-----------------------------------------------------------------------------
# Undistribute files
#-----------------------------------------------------------------------------

pfundist $runname
pfundist $ip0
pfundist $sx
pfundist $sy
pfundist $si


# #-----------------------------------------------------------------------------
# # Calculate Flow using Mannings equation on USGS stations
# # units = m3/s
# #-----------------------------------------------------------------------------

# set timesteps [expr $stoptime/24]
# set mask [pfload $runname.out.mask.pfb]
# set top [pfcomputetop $mask]

# set fobsfile [open ./parflow_input/fobs_location.txt r 0600]
# set calculated_obs_file [open lw_obs_out.txt w ]
# set fnobs [gets $fobsfile]


# for {set i 1} {$i <= $fnobs} {incr i 1} {

#        gets $fobsfile flocation
#        set Xloca($i) [lindex $flocation 0]
#        set Yloca($i) [lindex $flocation 1]
#        set sx1 [pfgetelt $sx $Xloca($i) $Yloca($i) 0]
#        set sy1 [pfgetelt $sy $Xloca($i) $Yloca($i) 0]
#        set S($i) [expr ($sx1**2+$sy1**2)**0.5]
#        puts stdout "Slope at $Xloca($i) $Yloca($i) = $S($i)"

#        for {set ii 1} {$ii <=$timesteps } {incr ii} {

#        set press [pfload [format $runname.out.press.%05d.pfb $ii]]
#        set P($i) [pfgetelt $press $Xloca($i) $Yloca($i) 14]
#        set satur [pfload [format $runname.out.satur.%05d.silo $ii]]

# # water table depth
#        set water_table_depth [pfwatertabledepth $top $satur]
#        set var "WT_depth"
#        set fout_silo [format $var.%03d.silo $ii]
#        pfsave $water_table_depth  -silo $fout_silo


#     #-----------------------------------------------------------------------------       
# # Clean up to avoid memory leaks...
# #-----------------------------------------------------------------------------

#        pfdelete $press
#        unset press
#        pfdelete $satur
#        unset satur

       
# ## set P($i)=0 when $P($i)<=0
#        if {$P($i) >= 0} { 
#           puts stdout "Top Pressure at USGS station $i = $P($i) at time $ii"      
#        }  else { 
#           set P($i) 0
#        }         

#        set QT($i) [expr ($dx/$n)*($S($i)**0.5)*($P($i)**(5./3.))/3600]    
#        puts $calculated_obs_file "calculated flow at USGS station $i = $QT($i)"

   
# }
       
# }
#        close $fobsfile
#        close $calculated_obs_file

# source $water_balance_script
puts "...DONE."
