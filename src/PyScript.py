
import os
import numpy as np
import sys

# Set working directory to the folder containing the script or executable
#if getattr(sys, 'frozen', False):  # If running as a compiled executable
#    os.chdir(os.path.dirname(sys.executable))
#else:
#    os.chdir(os.path.dirname(os.path.abspath(__file__)))

# Input and output file paths
input_file = 'in1.txt'
temp_output = 'tempout.txt'
final_output = 'out1.txt'

## Check if the input file exists
if not os.path.isfile(input_file):
    raise FileNotFoundError("The input file does not exist. Please ensure the file is in the working directory.")
print(f'Current Working Directory: {os.getcwd()}')

#Reading the input file and performing calculations
try:
    # Reading the content
    with open(input_file, 'r') as file:
        datainp = np.atleast_2d(np.loadtxt(file, comments='%'))
        datainpT = np.transpose(datainp)
    
    print('All DOEs')
    print(datainp)
    print(datainpT)
    dataout = []

    for row in datainpT:
        # Display the data in the Python console
        print('this DOE')
        print(f'DOE {row}')
        print('row')
        print(row)
        # Perform simulations
        print('started FE running')
        runcmd = (f'comsolbatch -inputfile parameterExperiment.mph '
                  f'-pname LL_D1_Boss_Extrude1 -plist "{row[0]}[mm]" '
                  f'-methodcall methodcall1 -nosave')

        print(row[0])
        #print(row[1])
        #print(row[2])
        print('next DOE')
        status, cmdout = os.system(runcmd), None  # `os.system` does not capture command output.
        print('finished FE running')

        # Read the output file for results
        with open(temp_output, 'r') as outfile:
            data = np.loadtxt(outfile, comments='%')
            dataout.append(np.atleast_1d(data))
            print('results of simulation')
            print(dataout)

    # Convert results to a numpy array
    dataoutArray = np.array(dataout)

    # Write the results to the final output file
    with open(final_output, 'w') as final_outfile:
        np.savetxt(final_outfile, np.vstack(dataoutArray), fmt='%f', delimiter='\t')
    
    # Display a message confirming the output file creation
    print(f'Results have been written to {final_output}')

except Exception as e:
    # Handle errors (e.g., file not found or reading issue)
    print('An error occurred while reading the file or performing calculations.')
    print(str(e))