import matplotlib.pyplot as plt
import numpy as np
from scipy import interpolate


###########################################################


def create_array(file_path):
    arrays = []
    values = []
    with open(file_path, 'r') as file:
        for line in file:
            line = line.strip()
            if line == 'new':
                array = np.array(values, dtype=float)
                arrays.append(array)
                values = []
            else:
                values.append(float(line))
    return arrays


def attribute_phase(lst_pourcentages, gait):
    lst_phases = [[[lst_pourcentages[0], gait[0]]], [], [], [], [], []]

    current_state = 0

    current_angle = gait[0]
    previous_angle = gait[0]

    current_speed = 0
    previous_speed = 0

    current_acc = 0
    previous_acc = 0

    for i in range(1, len(gait), 1):
        previous_angle = current_angle
        current_angle = gait[i]

        previous_speed = current_speed
        current_speed = current_angle - previous_angle

        previous_acc = current_acc
        current_acc = current_speed - previous_speed

        if np.abs(current_angle - previous_angle) > 9:
            lst_phases[5].append([lst_pourcentages[i], gait[i]])
        elif current_state == 0 and current_speed >= 0:
            lst_phases[0].append([lst_pourcentages[i], gait[i]])
            current_state = 0
        elif current_state == 0 and current_speed < 0:  # and previous_speed <0:
            lst_phases[1].append([lst_pourcentages[i], gait[i]])
            current_state = 1
        elif current_state == 1 and current_speed <= 0:
            lst_phases[1].append([lst_pourcentages[i], gait[i]])
            current_state = 1
        elif current_state == 1 and current_speed > 0:  # and previous_speed >0:
            lst_phases[2].append([lst_pourcentages[i], gait[i]])
            current_state = 2
        elif current_state == 2 and current_acc >= 0:
            lst_phases[2].append([lst_pourcentages[i], gait[i]])
            current_state = 2
        elif current_state == 2 and current_acc < 0:  # and previous_acc <0:
            lst_phases[3].append([lst_pourcentages[i], gait[i]])
            current_state = 3
        elif current_state == 3 and current_speed >= 0:
            lst_phases[3].append([lst_pourcentages[i], gait[i]])
            current_state = 3
        elif current_state == 3 and current_speed < 0:  # and previous_speed <0:
            lst_phases[4].append([lst_pourcentages[i], gait[i]])
            current_state = 4
        elif current_state == 4:
            lst_phases[4].append([lst_pourcentages[i], gait[i]])
            current_state = 4
        else:
            lst_phases[5].append([lst_pourcentages[i], gait[i]])
    return lst_phases


################################################################

phase_1_pourcentage = np.linspace(0, 15, 100)
phase_2_pourcentage = np.linspace(15, 41, 100)
phase_3_pourcentage = np.linspace(41, 60, 100)
phase_4_pourcentage = np.linspace(60, 75, 100)
phase_5_pourcentage = np.linspace(75, 100, 100)

standard_values = np.array(
    [[0, 6, 13],
     [5, 11, 17],
     [10, 17, 25],
     [15, 20, 27],
     [20, 17, 25],
     [25, 12, 19],
     [30, 8, 15],
     [35, 4, 12],
     [40, 1, 10],
     [45, 2, 11],
     [50, 5, 14],
     [55, 12, 20],
     [60, 22, 31],
     [65, 37, 47],
     [70, 52, 60, ],
     [75, 55, 65],
     [80, 52, 60],
     [85, 37, 47],
     [90, 20, 30],
     [95, 8, 15],
     [100, 5, 12],
     ]
)

lower_line = interpolate.interp1d(standard_values[:, 0], standard_values[:, 1], kind='cubic')

upper_line = interpolate.interp1d(standard_values[:, 0], standard_values[:, 2], kind='cubic')

lst_pourcentages = np.linspace(0, 100, 1000)


###############################################################################################
"""
Format du file
column with the angle value and the different cycles divided by "new" 
"""

file_path = 'post_analysis.txt'  # Replace with your file path
arrays = create_array(file_path)

###############################################################################################


lst_legend = ["Real 1st phase", "Real 2nd phase", "Real 3rd phase", "Real 4th phase", "Real 5th phase",
              "out of range"]
lst_color = ["#BA0C2F", "#981D97", "#009CA6", "#78BE20", "#FFD100", "red"]

plt.title("Gait analysis")

for array, cz in zip(arrays, range(0, len(arrays))):
    print(array)
    if len(array) != 0:
        lst_pourcentages = np.linspace(0,100,len(array))
        lst_phases = attribute_phase(lst_pourcentages, array)
        print(lst_phases)
        for l, leg, c in zip(lst_phases, lst_legend, lst_color):
            if len(l) != 0:
                lst_p = []
                lst_a = []
                for j in l:
                    lst_p.append(j[0])
                    lst_a.append(j[1])
                if cz == len(arrays)-1:
                    plt.plot(lst_p, lst_a, label=leg, color=c)
                    plt.legend()
                else:
                    plt.plot(lst_p, lst_a, color=c)

##################################################################################################

plt.plot(np.linspace(0, 100, 1000), lower_line(np.linspace(0, 100, 1000)), color="black")
plt.plot(np.linspace(0, 100, 1000), upper_line(np.linspace(0, 100, 1000)), color="black")

plt.fill_between(phase_1_pourcentage, lower_line(phase_1_pourcentage), upper_line(phase_1_pourcentage), color="#BA0C2F",
                 alpha=0.3, label="Theoretical  1st phase")
plt.fill_between(phase_2_pourcentage, lower_line(phase_2_pourcentage), upper_line(phase_2_pourcentage), color="#981D97",
                 alpha=0.3, label="Theoretical  2nd phase")
plt.fill_between(phase_3_pourcentage, lower_line(phase_3_pourcentage), upper_line(phase_3_pourcentage), color="#009CA6",
                 alpha=0.3, label="Theoretical  3rd phase")
plt.fill_between(phase_4_pourcentage, lower_line(phase_4_pourcentage), upper_line(phase_4_pourcentage), color="#78BE20",
                 alpha=0.3, label="Theoretical  4th phase")
plt.fill_between(phase_5_pourcentage, lower_line(phase_5_pourcentage), upper_line(phase_5_pourcentage), color="#FFD100",
                 alpha=0.3, label="Theoretical  5th phase")

plt.xlabel("% gait cycle")
plt.ylabel("Knee angle (deg)")
plt.ylim(0, 90)
plt.legend(loc='upper left',
           ncol=2, fancybox=True, shadow=True, prop={'size': 9})
plt.show()
print("over")
