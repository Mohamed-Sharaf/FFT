'''
                                        Radix 4 FFT Butterfly Unit        

Description :           This code is designed to implement radix 4 FFT Butterfly Unit. 
                It calculates the appropriate output according to input samples values and twiddle factor value.

Date: 05/2023
Author : Mohamed Sharaf
'''

from math import *
def butterfly_unit (input_0,input_1,input_2,input_3,twiddle_1,twiddle_2,twiddle_3):

    result = []
    x_0 = input_0 + input_1 + input_2 + input_3
    result.append(x_0)

    x_1 = (input_0 - 1j*input_1 - input_2 + 1j*input_3)*(twiddle_1)
    result.append(x_1)

    x_2 = (input_0 - input_1 + input_2 - input_3)*(twiddle_2)
    result.append(x_2)

    x_3 = (input_0 + 1j*input_1 - input_2 - 1j*input_3) * (twiddle_3)
    result.append(x_3)

    return result
