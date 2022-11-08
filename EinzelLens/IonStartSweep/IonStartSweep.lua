--[[
    IonStartSweep.lua - scan the voltage of the steering plates and record amount of steering
]]

simion.workbench_program()

adjustable KE_start = 0 -- First KE
adjustable KE_step = 5 -- KE step size
adjustable KE_stop = 50 -- Last KE

adjustable Ang_start = 0 -- First cone angle
adjustable Ang_step = 10 -- Cone angle step size
adjustable Ang_stop = 50 -- Last cone angle

adjustable excel_enable = 0  -- Use Excel? (1=yes, 0=no)

local KE_val   -- present voltage on V1
local Ang_val  -- present voltage on V3
local nions    -- number of ions to fly

nions = 200 -- adjust number of ions here

function segment.flym()
  sim_trajectory_image_control = 1 -- don't keep trajectories

  -- Step through all combinations of energy and cone angle.
  for KE_pos = 1,math.ceil(math.abs((KE_start-KE_stop)/KE_step))+1 do
    -- Update KE
    KE_val = KE_start + (KE_pos - 1) * KE_step
    for Ang_pos = 1,math.ceil(math.abs((Ang_start-Ang_stop)/Ang_step))+1 do
        -- Update cone angle 
        Ang_val = Ang_start + (Ang_pos - 1) * Ang_step
        -- Regenerate particle definitions in case FE cathode properties changed.
        local PL = simion.import 'particlelib.lua'
        PL.reload_fly2('IonStartSweep.fly2', {
        -- variables to pass to FLY2 file.
        KE_val=KE_val,
        Ang_val=Ang_val,
        nions=nions
        })
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
  file = io.open("data\\IonStartSweepData_KE_"..string.format("%02d",KE_val).."_CA_"..string.format("%02d",Ang_val)..".csv", 'w')
  file:write("Generated from IonStartSweep.iob -- KE = ",string.format("%02d",KE_val),"eV ConeAngle = ",string.format("%02d",Ang_val),"deg\nFinal-Y-pos(mm), Final-Z-pos(mm)")
end

  -- called on every time-step for each particle in PA instance.
function segment.other_actions()
  -- Update the PE surface display on first time-step of run.
  if first 
  then 
    first = false
    sim_update_pe_surface = 1
  end
  -- These if conditionals are checked each time-step on each ion in the run. Very useful for recording individual ion data at some point in the run.
  -- Record splat location for each ion (specifically leaving workbench)
  if (ion_splat == -3)
  then
    file:write('\n',tostring(ion_py_mm),",",tostring(ion_pz_mm))
  end
end