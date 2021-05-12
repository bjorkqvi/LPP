# LPP
LainePoiss processing functions

Function to process the raw data measured by the LainePoiss wave buoy, developed by WiseParker and TalTech

## Ways to process
# To get 30 minute files
NR-files >> LPP_acc_nr2nc.m >> LPP_acc2disp_30min.m >> LPP_disp2spec.m >> LPP_spec2param.m 
# To use NR files directly
NR-files >> LPP_acc2disp_nr.m >> LPP_disp2spec.m >> LPP_spec2param.m 
