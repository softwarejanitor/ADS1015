require("I2C");

// Create an I2C instance
i2c <- I2C(0);

// Load the library.
dofile("sd:/ADS1015.nut");

print("Getting single-ended readings from AIN0..3\n");
print("ADC Range: +/- 6.144V (1 bit = 3mV/ADS1015, 0.1875mV/ADS1115)\n");

// Instantiate the object
//local ads = ADS1015(i2c, 0x48, 1115);    /* Use this for the 16-bit version */
local ads = ADS1015(i2c, 0x48, 1015);    /* Use thi for the 12-bit version */

while (1) {
    local adc0;
    local adc1;
    local adc2;
    local adc3;

    adc0 = ads.readADC_SingleEnded(0);
    adc1 = ads.readADC_SingleEnded(1);
    adc2 = ads.readADC_SingleEnded(2);
    adc3 = ads.readADC_SingleEnded(3);
    print("AIN0: " + adc0 + "\n");
    print("AIN1: " + adc1 + "\n");
    print("AIN2: " + adc2 + "\n");
    print("AIN3: " + adc3 + "\n");
    print("\n");

    delay(1000);
}

