# Draining test fro Reynolds Creek Mountain East, modifications were made based on the scripts Miguel provided by Chao, Dec.4, 2017
# SCRIPT TO RUN DCEW DOMAIN WITHOUT CLM TERRAIN-FOLLOWING GRID
# DETAILS:
# -- SPATIALLY DISTRIBUTED SOILS ALL DIMENSIONS
# -- 20M SUBSURFACE (1M:soil, 19M: bedrock)
# -- HYDROSTATIC IC @ -10M (For spin-up purpouses)
# -- units m/hr

# Import the ParFlow TCL package
lappend   auto_path $env(PARFLOW_DIR)/bin
package   require parflow
namespace import Parflow::*

pfset     FileVersion    4

#-----------------------------------------------------------------------------
# Processor topology (P=x-direction,Q=y-direction,R=z-direction)
#-----------------------------------------------------------------------------
# pfset Process.Topology.P                  2
# pfset Process.Topology.Q                  2
# pfset Process.Topology.R                  1
source "/home/chaochen/payette/chaochen/CZO/Chao/RME_200mthick_40_1soil_new/pf_scripts/dimension.tcl"

#-----------------------------------------------------------------------------
# Set up run outputs
#-----------------------------------------------------------------------------
exec mkdir "../outputs"
cd "../outputs"

# ----------------------------------------------------------------------------
# Set up run input paths
# ----------------------------------------------------------------------------
# Paths:
# path to parflow_input
set pfindir     "../parflow_input"
# path to soil indicator 
set siindir     "../parflow_input/geo_indi"
# path to initial condition file
# set icdir       "../initialcond"

# ----------------------------------------------------------------------------
# Set up run input file names
# ----------------------------------------------------------------------------
# Files:
# initial condition file from last drainage output 
#set ic0     "pf_DrainingTest_step2.out.press.00237.pfb"
# slope files
set sx      "RCCZO_RME_DEMfil.sx.pfb"
set sy      "RCCZO_RME_DEMfil.sy.pfb"
# soil indicator file
set si      "RCCZO_RME_DEMfil.indi.pfb"

#-----------------------------------------------------------------------------
# Set up run info
#-----------------------------------------------------------------------------
set runname                               "pf_step1"
# set startcount                            237
# set starttime                             23700
set startcount                            0
set starttime                             0
# set stoptime                              23701
# set dmpinterval				              1
set stoptime                              43800
set dmpinterval				              168
set tstep				                  1
set rainvalue				              -0.0001
# set rainvalue				              0
set icpress				                  -10.0

set x0                                    0.0
set y0                                    0.0
set z0                                    -200.0

set nx                                    192
set ny                                    203
set nz                                    40  

set dx                                    5.0
set dy                                    5.0
set dz                                    5.0

#-----------------------------------------------------------------------------
# Soil paramameters (Van Genuchten)
#-----------------------------------------------------------------------------

# ---------- Bed Rock (BR) ----------

set Perm_val_BR				  0.000001			
set Poros_val_BR			  0.0004

set RPerm_alpha_BR			  3.5
set RPerm_n_BR				  2.0
set S_alpha_BR				  3.5
set S_n_BR				    2.0

set S_sres_BR				  0.126
#set S_sres_BR				  0.000001
set S_ssat_BR				  1.0

# ---------- Loamy sand (LS) ----------
set Perm_val_LS				  0.1459			
set Poros_val_LS			  0.41

set RPerm_alpha_LS			  12.4
set RPerm_n_LS				  2.28
set S_alpha_LS				  12.4
set S_n_LS				  2.28

#set S_sres_LS                             0.000001
set S_sres_LS				  0.057
set S_ssat_LS				  1.0
			
# ---------- Sandy loam (SL) ----------
set Perm_val_SL				  0.0442	
set Poros_val_SL			  0.41

set RPerm_alpha_SL			  7.5
set RPerm_n_SL			   	  1.89
set S_alpha_SL				  7.5
set S_n_SL				  1.89

#set S_sres_SL                             0.000001
set S_sres_SL				  0.065
set S_ssat_SL				  1.0		
	
# # ---------- Sandy clay loam (SCL) ----------
# set Perm_val_SCL			  0.0131	
# set Poros_val_SCL			  0.39

# set RPerm_alpha_SCL			  5.9
# set RPerm_n_SCL			   	  1.48
# set S_alpha_SCL				  5.9
# set S_n_SCL				  1.48

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

set S_sres_SCL                            0.1
#set S_sres_SCL				  0.000001
set S_ssat_SCL				  1.0		

# ---------- Loam (L) ----------
set Perm_val_L				  0.0104	
set Poros_val_L			  	  0.43

set RPerm_alpha_L			  3.6
set RPerm_n_L			   	  1.56
set S_alpha_L				  3.6
set S_n_L				      1.56

set S_sres_L                              0.078
#set S_sres_L				  0.000001
set S_ssat_L				  1.0

# ---------- Clay (C) ----------
set Perm_val_C				  0.0104	
set Poros_val_C			  	  0.43

set RPerm_alpha_C			  3.6
set RPerm_n_C			   	  1.56
set S_alpha_C				  3.6
set S_n_C				  1.56

set S_sres_C                              0.068
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


#-----------------------------------------------------------------------------
# Copy input files to run directory
# ----------------------------------------------------------------------------
# ParFlow Input
file copy -force    $pfindir/$sx          .
file copy -force    $pfindir/$sy          .
file copy -force    $siindir/$si          .
#file copy -force    $icdir/$ic0           .



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

pfset Solver.Nonlinear.VariableDz       True
pfset dzScale.GeomNames                 domain
pfset dzScale.Type                      nzList
pfset dzScale.nzListNumber              40

pfset	Cell.0.dzScale.Value	3
pfset	Cell.1.dzScale.Value	3
pfset	Cell.2.dzScale.Value	2
pfset	Cell.3.dzScale.Value	2
pfset	Cell.4.dzScale.Value	2
pfset	Cell.5.dzScale.Value	2
pfset	Cell.6.dzScale.Value	2
pfset	Cell.7.dzScale.Value	2
pfset	Cell.8.dzScale.Value	2
pfset	Cell.9.dzScale.Value	2
pfset	Cell.10.dzScale.Value	2
pfset	Cell.11.dzScale.Value	2
pfset	Cell.12.dzScale.Value	2
pfset	Cell.13.dzScale.Value	2
pfset	Cell.14.dzScale.Value	1
pfset	Cell.15.dzScale.Value	1
pfset	Cell.16.dzScale.Value	1
pfset	Cell.17.dzScale.Value	1
pfset	Cell.18.dzScale.Value	1
pfset	Cell.19.dzScale.Value	1
pfset	Cell.20.dzScale.Value	0.4
pfset	Cell.21.dzScale.Value	0.4
pfset	Cell.22.dzScale.Value	0.4
pfset	Cell.23.dzScale.Value	0.4
pfset	Cell.24.dzScale.Value	0.4
pfset	Cell.25.dzScale.Value	0.4
pfset	Cell.26.dzScale.Value	0.4
pfset	Cell.27.dzScale.Value	0.32
pfset	Cell.28.dzScale.Value	0.2
pfset	Cell.29.dzScale.Value	0.2
pfset	Cell.30.dzScale.Value	0.06
pfset	Cell.31.dzScale.Value	0.06
pfset	Cell.32.dzScale.Value	0.06
pfset	Cell.33.dzScale.Value	0.06
pfset	Cell.34.dzScale.Value	0.06
pfset	Cell.35.dzScale.Value	0.06
pfset	Cell.36.dzScale.Value	0.06
pfset	Cell.37.dzScale.Value	0.03
pfset	Cell.38.dzScale.Value	0.02
pfset	Cell.39.dzScale.Value	0.01


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
# pfset Domain.GeomName                     "domain"
# suggested by the manual, there is no quot in the name
pfset Domain.GeomName                     domain

#-----------------------------------------------------------------------------
# Names of the GeomInputs
#-----------------------------------------------------------------------------
#pfset GeomInput.Names                     "box_input indi_input"
# pfset GeomInput.Names                     "solidinput box_input indi_input"
pfset GeomInput.Names "box_input indi_input"

#-----------------------------------------------------------------------------
# SolidFile Geometry Input
#-----------------------------------------------------------------------------
# pfset GeomInput.solidinput.InputType      SolidFile
# pfset GeomInput.solidinput.GeomName      "domain"

pfset GeomInput.box_input.InputType      Box
pfset GeomInput.box_input.GeomName      "domain"


# #---------------------------------------------------------
# # Domain Geometry 
# #---------------------------------------------------------
pfset Geom.domain.Lower.X                        $x0
pfset Geom.domain.Lower.Y                        $y0
pfset Geom.domain.Lower.Z                        $z0
 
pfset Geom.domain.Upper.X                        960.0
pfset Geom.domain.Upper.Y                        1015.0
pfset Geom.domain.Upper.Z                        0.0
pfset Geom.domain.Patches             "x-lower x-upper y-lower y-upper z-lower z-upper"


#-----------------------------------------------------------------------------
# Indicator Geometry Input
#-----------------------------------------------------------------------------

pfset GeomInput.indi_input.InputType      IndicatorField
#pfset GeomInput.indi_input.GeomNames      "F1 F2 F3 F4 F5 F6"
pfset GeomInput.indi_input.GeomNames      "F1 F2 F3"
pfset Geom.indi_input.FileName      $si

# Geometry input values

pfset GeomInput.F1.Value          0
pfset GeomInput.F2.Value          120
pfset GeomInput.F3.Value          121
#pfset GeomInput.F4.Value          4
#pfset GeomInput.F5.Value          5
#pfset GeomInput.F6.Value          6


#-----------------------------------------------------------------------------
# Permeability (values in m/hr)
#-----------------------------------------------------------------------------
#pfset Geom.Perm.Names          "domain F1 F2 F3 F4 F5 F6"
pfset Geom.Perm.Names          "domain F1 F2 F3"

pfset Geom.domain.Perm.Type       Constant
pfset Geom.domain.Perm.Value      $Perm_val_LS

# Permeability input values
pfset Geom.F1.Perm.Type     Constant
pfset Geom.F1.Perm.Value    $Perm_val_BR

# pfset Geom.F1.Perm.Type "TurnBands"
# pfset Geom.F1.Perm.LambdaX  1
# pfset Geom.F1.Perm.LambdaY  1
# pfset Geom.F1.Perm.LambdaZ  1

# #pfset Geom.F1.Perm.GeomMean 0.002
# #pfset Geom.F1.Perm.Sigma   1.0
# #pfset Geom.F1.Perm.Sigma   0.48989794
# pfset Geom.F1.Perm.NumLines 150
# pfset Geom.F1.Perm.RZeta  5.0
# pfset Geom.F1.Perm.KMax  300.0000001
# pfset Geom.F1.Perm.DelK  0.2
# #pfset Geom.F1.Perm.Seed  33333
# pfset Geom.F1.Perm.LogNormal Log
# pfset Geom.F1.Perm.StratType Bottom

pfset Geom.F2.Perm.Type     Constant
pfset Geom.F2.Perm.Value    $Perm_val_SCL
pfset Geom.F3.Perm.Type     Constant
pfset Geom.F3.Perm.Value    $Perm_val_L
#pfset Geom.F4.Perm.Type     Constant
#pfset Geom.F4.Perm.Value    $Perm_val_LS
#pfset Geom.F5.Perm.Type     Constant
#pfset Geom.F5.Perm.Value    $Perm_val_SCL
#pfset Geom.F6.Perm.Type     Constant
#pfset Geom.F6.Perm.Value    $Perm_val_SL

# # we open a file, to read geo mean and standard deviation
# set fn "/home/chaochen/build_apps/parflow-3.2.0/test/stats4.txt"
# set fileId [open $fn r 0600]
# set kgl [gets $fileId]
# set varl [gets $fileId]
# close $fileId

# # set kgl 0.00875
# # set varl 0.5
# pfset Geom.F1.Perm.GeomMean  $kgl
# pfset Geom.F1.Perm.Sigma  $varl


# pfset Perm.TensorType               TensorByGeom

# pfset Geom.Perm.TensorByGeom.Names  "domain"

# pfset Geom.domain.Perm.TensorValX  1.0
# pfset Geom.domain.Perm.TensorValY  1.0
# pfset Geom.domain.Perm.TensorValZ  1.0



#-----------------------------------------------------------------------------
# Porosity
#-----------------------------------------------------------------------------
# pfset Geom.Porosity.GeomNames      domain

# pfset Geom.domain.Porosity.Type    Constant
# pfset Geom.domain.Porosity.Value   0.390

#pfset Geom.Porosity.GeomNames          "domain F1 F2 F3 F4 F5 F6"
pfset Geom.Porosity.GeomNames          "domain F1 F2 F3"

pfset Geom.domain.Porosity.Type       Constant
pfset Geom.domain.Porosity.Value      $Poros_val_LS

# Porosity input values
pfset Geom.F1.Porosity.Type     Constant
pfset Geom.F1.Porosity.Value    $Poros_val_BR
pfset Geom.F2.Porosity.Type     Constant
pfset Geom.F2.Porosity.Value    $Poros_val_SCL
pfset Geom.F3.Porosity.Type     Constant
pfset Geom.F3.Porosity.Value    $Poros_val_L
#pfset Geom.F4.Porosity.Type     Constant
#pfset Geom.F4.Porosity.Value    $Poros_val_LS
#pfset Geom.F5.Porosity.Type     Constant
#pfset Geom.F5.Porosity.Value    $Poros_val_SCL
#pfset Geom.F6.Porosity.Type     Constant
#pfset Geom.F6.Porosity.Value    $Poros_val_SL

#-----------------------------------------------------------------------------
# Relative Permeability 
#-----------------------------------------------------------------------------

pfset Phase.RelPerm.Type              VanGenuchten
#pfset Phase.RelPerm.GeomNames          "domain F1 F2 F3 F4 F5 F6"
pfset Phase.RelPerm.GeomNames          "domain F1 F2 F3"

pfset Geom.domain.RelPerm.Alpha       $RPerm_alpha_LS
pfset Geom.domain.RelPerm.N           $RPerm_n_LS

# Relative Permeability input values
pfset Geom.F1.RelPerm.Alpha    $RPerm_alpha_BR
pfset Geom.F1.RelPerm.N        $RPerm_n_BR
pfset Geom.F2.RelPerm.Alpha    $RPerm_alpha_SCL
pfset Geom.F2.RelPerm.N        $RPerm_n_SCL
pfset Geom.F3.RelPerm.Alpha    $RPerm_alpha_L
pfset Geom.F3.RelPerm.N        $RPerm_n_L
#pfset Geom.F4.RelPerm.Alpha    $RPerm_alpha_LS
#pfset Geom.F4.RelPerm.N        $RPerm_n_LS
#pfset Geom.F5.RelPerm.Alpha    $RPerm_alpha_SCL
#pfset Geom.F5.RelPerm.N        $RPerm_n_SCL
#pfset Geom.F6.RelPerm.Alpha    $RPerm_alpha_SL
#pfset Geom.F6.RelPerm.N        $RPerm_n_SL

# pfset Phase.RelPerm.Type              VanGenuchten
# pfset Phase.RelPerm.GeomNames          "domain"

# pfset Geom.domain.RelPerm.Alpha       $RPerm_alpha_LS
# pfset Geom.domain.RelPerm.N           $RPerm_n_LS

#-----------------------------------------------------------------------------
# Saturation 
#-----------------------------------------------------------------------------

pfset Phase.Saturation.Type               VanGenuchten
#pfset Phase.Saturation.GeomNames          "domain F1 F2 F3 F4 F5 F6"
pfset Phase.Saturation.GeomNames          "domain F1 F2 F3"

pfset Geom.domain.Saturation.Alpha       $S_alpha_LS
pfset Geom.domain.Saturation.N           $S_n_LS
pfset Geom.domain.Saturation.SRes        $S_sres_LS
pfset Geom.domain.Saturation.SSat        $S_ssat_LS

# Saturation input values
pfset Geom.F1.Saturation.Alpha    $S_alpha_BR
pfset Geom.F1.Saturation.N        $S_n_BR
pfset Geom.F1.Saturation.SRes     $S_sres_BR
pfset Geom.F1.Saturation.SSat     $S_ssat_BR
pfset Geom.F2.Saturation.Alpha    $S_alpha_SCL
pfset Geom.F2.Saturation.N        $S_n_SCL
pfset Geom.F2.Saturation.SRes     $S_sres_SCL
pfset Geom.F2.Saturation.SSat     $S_ssat_SCL
pfset Geom.F3.Saturation.Alpha    $S_alpha_L
pfset Geom.F3.Saturation.N        $S_n_L
pfset Geom.F3.Saturation.SRes     $S_sres_L
pfset Geom.F3.Saturation.SSat     $S_ssat_L
#pfset Geom.F4.Saturation.Alpha    $S_alpha_LS
#pfset Geom.F4.Saturation.N        $S_n_LS
#pfset Geom.F4.Saturation.SRes     $S_sres_LS
#pfset Geom.F4.Saturation.SSat     $S_ssat_LS
#pfset Geom.F5.Saturation.Alpha    $S_alpha_SCL
#pfset Geom.F5.Saturation.N        $S_n_SCL
#pfset Geom.F5.Saturation.SRes     $S_sres_SCL
#pfset Geom.F5.Saturation.SSat     $S_ssat_SCL
#pfset Geom.F6.Saturation.Alpha    $S_alpha_SL
#pfset Geom.F6.Saturation.N        $S_n_SL
#pfset Geom.F6.Saturation.SRes     $S_sres_SL
#pfset Geom.F6.Saturation.SSat     $S_ssat_SL

# pfset Phase.Saturation.Type               VanGenuchten
# pfset Phase.Saturation.GeomNames          "domain"

# pfset Geom.domain.Saturation.Alpha       $S_alpha_LS
# pfset Geom.domain.Saturation.N           $S_n_LS
# pfset Geom.domain.Saturation.SRes        $S_sres_LS
# pfset Geom.domain.Saturation.SSat        $S_ssat_LS
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
# Wells
#-----------------------------------------------------------------------------
pfset Wells.Names                         ""

#----------------------------------------------------------------------------
# Mobility
#----------------------------------------------------------------------------
pfset Phase.water.Mobility.Type        Constant
pfset Phase.water.Mobility.Value       1.0

#-----------------------------------------------------------------------------
# Time Cycles
#-----------------------------------------------------------------------------
#pfset Cycle.Names                         "constant rainrec"
pfset Cycle.Names                         "constant"
pfset Cycle.constant.Names                "alltime"
pfset Cycle.constant.alltime.Length       $stoptime
pfset Cycle.constant.Repeat               -1

#pfset Cycle.rainrec.Names                 "rain rec"
#pfset Cycle.rainrec.rain.Length           $rainlength
#pfset Cycle.rainrec.rec.Length            $reclength
#pfset Cycle.rainrec.Repeat                $repeatcycles

#-----------------------------------------------------------------------------
# Boundary Conditions: Pressure
#-----------------------------------------------------------------------------
pfset BCPressure.PatchNames                   [pfget Geom.domain.Patches]

pfset Patch.x-lower.BCPressure.Type		          FluxConst
pfset Patch.x-lower.BCPressure.Cycle		      "constant"
pfset Patch.x-lower.BCPressure.alltime.Value	      0.0

pfset Patch.y-lower.BCPressure.Type		          FluxConst
pfset Patch.y-lower.BCPressure.Cycle		      "constant"
pfset Patch.y-lower.BCPressure.alltime.Value	      0.0

pfset Patch.z-lower.BCPressure.Type		          FluxConst
pfset Patch.z-lower.BCPressure.Cycle		      "constant"
pfset Patch.z-lower.BCPressure.alltime.Value	      0.0

pfset Patch.x-upper.BCPressure.Type		          FluxConst
pfset Patch.x-upper.BCPressure.Cycle		      "constant"
pfset Patch.x-upper.BCPressure.alltime.Value	      0.0

pfset Patch.y-upper.BCPressure.Type		          FluxConst
pfset Patch.y-upper.BCPressure.Cycle		      "constant"
pfset Patch.y-upper.BCPressure.alltime.Value	      0.0

pfset Patch.z-upper.BCPressure.Type		          OverlandFlow
pfset Patch.z-upper.BCPressure.Cycle		      "constant"
# constant recharge at 100 mm / y
pfset Patch.z-upper.BCPressure.alltime.Value	  $rainvalue

#-----------------------------------------------------------------------------
# Topo slopes in x-direction
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
pfset Mannings.Geom.domain.Value                      0.05

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

#-----------------------------------------------------------------------------
# Turn off the lateral flow (spin-up process)
#-----------------------------------------------------------------------------
pfset OverlandFlowSpinUp			  1
pfset OverlandSpinupDampP1			  10.0
pfset OverlandSpinupDampP2			  0.1

#---------------------------------------------------------
# Initial conditions: water pressure pfb-file
#---------------------------------------------------------
# pfset ICPressure.Type                                 PFBFile
# pfset ICPressure.GeomNames                            domain
# pfset Geom.domain.ICPressure.RefPatch                 z-upper
# pfset Geom.domain.ICPressure.FileName                 $ic0

#F---------------------------------------------------------
# Initial conditions: water pressure hydrostatic
#---------------------------------------------------------
pfset ICPressure.Type                                 HydroStaticPatch
pfset ICPressure.GeomNames                            domain
pfset Geom.domain.ICPressure.Value                    $icpress
pfset Geom.domain.ICPressure.RefGeom                  domain
pfset Geom.domain.ICPressure.RefPatch                 z-upper

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


## new solver settings for Terrain Following Grid

pfset Solver.Nonlinear.EtaChoice                         EtaConstant
pfset Solver.Nonlinear.EtaValue                          0.001
pfset Solver.Nonlinear.UseJacobian                       True 
pfset Solver.Nonlinear.DerivativeEpsilon                 1e-16
pfset Solver.Nonlinear.StepTol				 1e-30
pfset Solver.Nonlinear.Globalization                     LineSearch
pfset Solver.Nonlinear.MaxIter				 40
pfset Solver.Nonlinear.ResidualTol			 1e-6

pfset Solver.Linear.KrylovDimension                      70
pfset Solver.Linear.MaxRestarts                          2
pfset Solver.Linear.Preconditioner                       PFMG
pfset Solver.Linear.Preconditioner.PCMatrixType          FullJacobian
pfset Solver.Linear.Preconditioner.SymmetricMat          Nonsymmetric

#Writing output (no binary except Pressure, all silo):
pfset Solver.PrintSubsurfData                         True
pfset Solver.PrintPressure                            True
pfset Solver.PrintSaturation                          True
pfset Solver.WriteCLMBinary                           False

pfset Solver.WriteSiloSpecificStorage                 True
pfset Solver.WriteSiloMannings                        False
pfset Solver.WriteSiloMask                            True
pfset Solver.WriteSiloSlopes                          False
pfset Solver.WriteSiloSubsurfData                     True
pfset Solver.WriteSiloPressure                        False
pfset Solver.WriteSiloSaturation                      False
pfset Solver.WriteSiloEvapTrans                       False
pfset Solver.WriteSiloEvapTransSum                    False
pfset Solver.WriteSiloOverlandSum                     False
pfset Solver.WriteSiloCLM                             False


#-----------------------------------------------------------------------------
# Run test
#-----------------------------------------------------------------------------
puts " "
puts "Distributing input files..."
pfset ComputationalGrid.NX                $nx 
pfset ComputationalGrid.NY                $ny 
pfset ComputationalGrid.NZ                1
pfdist $sx
pfdist $sy

pfset ComputationalGrid.NX                $nx 
pfset ComputationalGrid.NY                $ny 
pfset ComputationalGrid.NZ                $nz 
pfdist $si
# pfdist $ic0

puts " "
puts "Executing pfrun..."

pfrun	$runname
puts "1 2 3"

# #-----------------------------------------------------------------------------
# # Run and Unload the ParFlow output files
# #-----------------------------------------------------------------------------

# # # this script is setup to run 100 realizations, for testing we just run one
# #set n_runs 100
#  set n_runs 2

# #
# #  Loop through runs
# #
# for {set k 1} {$k <= $n_runs} {incr k 1} {
# #
# # set the random seed to be different for every run
# #
# pfset Geom.F1.Perm.Seed  [ expr 33333+2*$k ] 


# pfrun pf_test.$k
# pfundist pf_test.$k

# # we use pf tools to convert from pressure to head
# # we could do a number of other things here like copy files to different format

# set rnum [format "%05d" $startcount]
# set press [pfload $runname.$k.out.press.$rnum.pfb]
# set head [pfhhead $press]
# pfsave $head -pfb $runname.$k.head.$rnum.pfb

# }





#-----------------------------------------------------------------------------
# Undistribute files
#-----------------------------------------------------------------------------
puts "Undistributing files"
pfundist $runname
pfundist $sx
pfundist $sy
pfundist $si
#pfundist $ic0

puts "...DONE."
