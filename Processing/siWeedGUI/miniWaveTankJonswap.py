from mhkit import wave
import numpy as np
import matplotlib.pylab as plt
import sys

def main(Hm0,Tp,gamma):

	# Hm0 = sys.argv[1];
	# Tp = sys.argv[2];
	# gamma = sys.argv[3];

	# gamma = 9
	# Tp = 1/3
	# Hm0 = 5e-2

	f_low = 2
	f_high = 4
	df = 1/5

	f = np.arange(f_low, f_high, df)
	S = wave.resource.jonswap_spectrum(f, Tp, Hm0, gamma)
	print(S)

	# return S.S.values and S.f.values

if __name__ == '__main__':
	# Hm0 = sys.argv[1]
	# Tp = sys.argv[2]
	# gamma = sys.argv[3]
	S = main(5e-2,1/3,7)
