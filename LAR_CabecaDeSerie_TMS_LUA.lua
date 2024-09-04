-- This script is an example of reading a analog pin, PWM in and GPIO

-- for these examples BRD_PWM_COUNT must be 0

---@diagnostic disable: need-check-nil

-- load the analog pin, there are only 16 of these available
-- some are used by the main AP code, ie battery monitors
-- assign them like this in the init, not in the main loop
local analog_in = analog:channel()
if not analog_in:set_pin(13) then -- typically 13 is the battery input
  gcs:send_text(0, "Invalid analog pin")
end

-- load a input pwm pin
local pwm_in = PWMSource()
local pwm_in_fail = PWMSource()

if not pwm_in:set_pin(50) then -- AUX 1
  gcs:send_text(0, "Failed to setup PWM in on pin 50")
end

-- there are a few combinations of PWM in that will not work
-- this is due to the way interrupts are handled, AUX 1 and 6 cannot both
-- be PWM at once because they use the same interrupt (on Cubes), this should fail
if not pwm_in_fail:set_pin(55) then -- AUX 6
  gcs:send_text(0, "Failed to setup PWM in on pin 55")
end

gpio:pinMode(51,1) -- set AUX 2 to output, gpio:pinMode(51,0) would be input

function update()
  -- gcs:send_text(0, string.format("voltage: %0.2f, PWM: %i, input: ", analog_in:voltage_average(), pwm_in:get_pwm_us()) .. tostring(gpio:read(51)))
  local voltage = analog_in:voltage_average() -- the average voltage since the last call
  local thermistorResist = ((voltage*100000)/(3.3-voltage))
  local temp = 1/((math.log(thermistorResist/10000)/3950)+(1/298.15))
  if (temp>50) then
    disarm()
  end
  -- analog_in:voltage_latest() the latest voltage reading
  -- analog_in:voltage_average_ratiometric() the average ratiometric voltage (relative to the board 5v)



  return update, 1000
end

return update() -- run immediately before starting to reschedule