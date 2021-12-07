# A 16 step sequencer and granulator built in SuperCollider

This sequencer functions as a stand-alone step sequencer in supercollider with a range of instruments and scales available. 

Each 'level' of the sequencer represents an octave range as represented by the rows of buttons and 16-steps in each measure (although you can also think of it as being 2 measures at 8-steps if you wish)

# Installation

Download <a href=https://supercollider.github.io>SuperCollider here.</a>

Next, yo can either download it via <a href=https://github.com/eclemmon/sequencer/archive/refs/heads/trunk.zip>this link</a>, or use the CLI to clone the repository using:

`git clone https://github.com/eclemmon/sequencer.git`

Then, navigate to the directory with the sequencer, open up the `main.scd` file, and hit execute the code in between the paranthesis using command+return.

# The GUI and the sequencer

![Alt text](/README_bin/gui_example.png "The Full GUI")

## Tabs, Track, and Sequencer Buttons

![Alt text](/README_bin/tabs_buttons.png "The Full GUI")

### Tabs

Each tab at the top left represents a different layer of sequencer buttons that can be set to create a greater range of polyphonic creativity. For simplicity's sake, they have been lables, melody, harmony, and bass for their defaul settings. During the course of a performance with this software, these positions can easily be switched in their respective roles, whether that be for the register most commonly associated with their name, or their function.

### Track

Just beneath the tabs is the sequencer track. The track merely shows where the playback 'head' is along the sequencer buttons. In the case of this image, the cell above the 5 column of buttons is colored, so during this time-frame any buttons pressed in the 5th column—whether it be melody, harmony, or bass will be played back.


### Sequencer Buttons

The columns represent time points in the sequencer pattern, ranging from 1-16. The rows represent the scale degrees played back. For example, in the ionian mode (major mode) out of the western concert music tradition, the scale degrees represent C-D-E-F-G-A-B-C. using the select scale menu in Control Panel 1 --> Scale Type, the mode can be changed. These scales include by default non-western scales, as well as more recently invented ones.

## Control Panel 1

![Alt text](/README_bin/control_panel_1.png "The Full GUI")

This control panel will control the settings of the sequencer. In some cases (note duration, volume, and instrument), the control will only set values for the particular tab that is selected.

### Speed

This slider controls the speed at which the patter iterates through the columns. Speed at 0.1 means each step of the sequencer advances after 1/10 of a second.

### Note Duration

This slider detrmines the length of each triggered note in the currently selected tab of the sequencer.

### Volume

This slider determines the amplitude of the currently selected tab of the sequencer.

### Scale Type

This menu selects a scale from which the rows/scale-degrees derive the frequency of their pitches from.

### Instrument

This selects the synthesizer in use by the currently selected tab layer of th sequencer.

### Clear Sequencer

This clears all the currently selected buttons accross all tabs in the sequencer.