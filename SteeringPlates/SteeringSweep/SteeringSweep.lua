--[[
    SteeringPlatesSweep.lua - scan the voltage of the steering plates and record amount of steering
]]

simion.workbench_program()

adjustable V1_start = -20 -- First V1 voltage
adjustable V3_start = -20 -- First V3 voltage
adjustable V1_step = 5 -- V1 voltage step size
adjustable V3_step = 5 -- V3 voltage step size
adjustable V1_stop = 20 -- Number of V1 voltage steps
adjustable V3_stop = 20 -- Number of V3 voltage steps
adjustable excel_enable = 0  -- Use Excel? (1=yes, 0=no)

local V1_voltage -- present voltage on V1
local V3_voltage -- present voltage on V3
local V1_sign -- polarity of V1_voltage
local V3_sign -- polarity of V3_voltage
local py_final -- final y position of ion
local pz_final -- final z position of ion

function segment.flym()
  sim_trajectory_image_control = 1 -- don't keep trajectories

  -- Step through all combinations of voltages V1 and V3.
  for V1_pos = 1,math.ceil(math.abs((V1_start-V1_stop)/V1_step)) do
    -- Update V1 voltage
    V1_voltage = V1_start + (V1_pos - 1) * V1_step
    if V1_voltage < 0
    then
      V1_sign = 'n'
    else
      V1_sign = 'p'
    end
    for V3_pos = 1,math.ceil(math.abs((V3_start-V3_stop)/V3_step)) do
      -- Update V3 voltage
      V3_voltage = V3_start + (V3_pos - 1) * V3_step
      if V3_voltage < 0
      then
        V3_sign = 'n'
      else
        V3_sign = 'p'
      end
      -- Perform trajectory calculation run.
      run()
      
    end
  end
  file:close()
end

-- called on start of each run.
local first
function segment.initialize_run()
  first = true
  py_final = {}
  pz_final = {}
end

-- called multiple times per time-step to adjust voltages.
function segment.fast_adjust()
    adj_elect01 = V1_voltage
    adj_elect03 = V3_voltage
  end

  -- called on every time-step for each particle in PA instance.
function segment.other_actions()
    -- Update the PE surface display on first time-step of run.
    if first 
    then 
      first = false
      sim_update_pe_surface = 1
      file = io.open("data\\SteeringSweepData_V1_"..V1_sign..tostring(math.abs(V1_voltage)).."_V3_"..V3_sign..tostring(math.abs(V3_voltage))..".csv", 'w')
      file:write("Generated from SteeringPlates.iob -- V1 = ",tostring(V1_voltage),"V V3 = ",tostring(V3_voltage),"V\nFinal Y pos (mm), Final Z pos (mm)")
    end
  end

function segment.terminate()
    --record final positions of ion in units
    file:write("\n",tostring(ion_py_mm),",",tostring(ion_pz_mm))
end