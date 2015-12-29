# PEEP-II-MRI-Script-Use-Scenarios

## Scenario 0

- **Location**: Anywhere
- **Devices**: No external devices.
- **Keys**: All keys (t, a, b, c, d, ESCAPE, etc.) are detected by laptop keyboard.
- **Status**: Implemented now.

## Scenario 1

- **Location**: Rick's office in 114 Moore.
- **Devices**: Apple External Keyboard, external monitor.
- **Keys**: ESCAPE key detected by internal laptop keyboard; t, a, b, c, d detected by external keyboard.
- **Status**: Implemented now.

## Scenario 2

- **Location**: 214 Moore.
- **Devices**: Dell keyboard.
- **Keys**: ESCAPE key detected by internal laptop keyboard; t, a, b, c, d detected by external keyboard.
- **Status**: This is not yet implemented. To implement it, I need to know the output from the following Matlab command (with the Dell keyboard attached):

		[keyboardIndices, productNames, ~] = GetKeyboardIndices()

## Scenario 3

- **Location**: SLEIC during pre-testing.
- **Devices**: External trigger and grips connected via USB; projector; Sensimetrics sound interface via USB.
- **Keys**: ESCAPE key detected by internal laptop keyboard; t detected from internal laptop keyboard OR scanner trigger; a, b, c, d detected from grips OR internal laptop keyboard.
- **Status**
  - 2015-12-xx: Has worked in the past without the Sensimetrics interface. This was added on 2015-12-22.
  - 2015-12-22: Failed to detect keypresses from internal laptop keyboard running either peep_mri.m or pre_scan_check.m per email from Pan Liu.

## Scenario 4

- **Location**: SLEIC running.
- **Devices**: External trigger and grips connected via USB; projector; Sensimetrics sound interface via USB.
- **Keys**: ESCAPE key detected from internal laptop keyboard; t detected from internal laptop keyboard OR scanner trigger; a, b, c, d detected by grips only.
- **Status**:
  - 2015-12-xx:
  - 2015-12-22: Failed to work. Internal keyboard did not detect keypresses. ROG suspects a bug in assigning keyboard queues to USB devices with the Sensimetrics device attached.

  | Input device           | Device Code        | Keys detected      |
  |------------------------|--------------------|--------------------|
  | External trigger       | 'TRIGI-USB'        | 't'                |
  | Nordic Neurolabs grips | 'KeyWarrior8 Flex' | 'a', 'b', 'c', 'd' |
  | Laptop keyboard        | 'Apple Internal Keyboard / Trackpad' | 't', 'ESCAPE' |
