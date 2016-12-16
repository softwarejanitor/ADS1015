require("I2C");

// Create an I2C instance
i2c <- I2C(0);

// Load the library.
dofile("sd:/ADS1015.nut");

print("Single-ended readings from AIN0 with >3.0V comparator\n");
print("ADC Range: +/- 6.144V (1 bit = 3mV/ADS1015, 0.1875mV/ADS1115)\n");
print("Comparator Threshold: 1000 (3.000V)\n");

// The ADC input range (or gain) can be changed via the following
// functions, but be careful never to exceed VDD +0.3V max, or to
// exceed the upper and lower limits if you adjust the input range!
// Setting these values incorrectly may destroy your ADC!
//                                                                ADS1015  ADS1115
//                                                                -------  -------
// ads.setGain(GAIN_TWOTHIRDS);  // 2/3x gain +/- 6.144V  1 bit = 3mV      0.1875mV (default)
// ads.setGain(GAIN_ONE);        // 1x gain   +/- 4.096V  1 bit = 2mV      0.125mV
// ads.setGain(GAIN_TWO);        // 2x gain   +/- 2.048V  1 bit = 1mV      0.0625mV
// ads.setGain(GAIN_FOUR);       // 4x gain   +/- 1.024V  1 bit = 0.5mV    0.03125mV
// ads.setGain(GAIN_EIGHT);      // 8x gain   +/- 0.512V  1 bit = 0.25mV   0.015625mV
// ads.setGain(GAIN_SIXTEEN);    // 16x gain  +/- 0.256V  1 bit = 0.125mV  0.0078125mV

// Instantiate the object
//local ads = ADS1015(i2c, 0x48, 1115);    /* Use this for the 16-bit version */
local ads = ADS1015(i2c, 0x48, 1015);    /* Use thi for the 12-bit version */

// Setup 3V comparator on channel 0
ads.startComparator_SingleEnded(0, 1000);

while (1) {
  local adc0;

  // Comparator will only de-assert after a read
  adc0 = ads.getLastConversionResults();
  print("AIN0: " + adc0 + "\n");

  delay(100);
}

