# Generate sin Data to CSV file.  
# Need to terminate lines with commas after generating file.

import numpy as np
import pandas as pd
t = np.linspace(0,359, 256)

V = np.array(np.round(127 * np.sin(np.deg2rad(t)) + 128), dtype=int)
Vd = pd.DataFrame(np.reshape(V, (32, 8)))
Vd.to_csv("sinData.csv", index=False)
