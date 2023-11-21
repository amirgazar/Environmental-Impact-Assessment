# Transborder electrical interties do not create environmental impacts from development of Canadian hydroelectric resources
# Amir Mortazavigazar1,2,*, Mark E. Borsuk3, Ryan S.D. Calder1,2,3,4,5
# 1 Department of Population Health Sciences, Virginia Tech, Blacksburg, VA, 24061, USA
# 2 Global Change Center, Virginia Tech, Blacksburg, VA, 24061, USA
# 3 Department of Civil and Environmental Engineering, Duke University, Durham, NC, 27708, USA
# 4 Faculty of Health Sciences, Virginia Tech, Roanoke, VA, 24016, USA
# 5 Department of Civil and Environmental Engineering, Virginia Tech, Blacksburg, VA, 24061, USA

# *Contact: amirgazar@vt.edu.   
# All rights reserved under Creative Commons 4.0

import matplotlib.pyplot as plt
import pandas as pd

# import the dataset hydro_var_aug23.csv using pandas as a dataframe
df = pd.read_csv("/content/drive/MyDrive/Colab Notebooks/hydro_var_aug23.csv")

fig, ax1 = plt.subplots()

# Bar plot for INSTALLED
ax1.bar(df['Year'], df['INSTALLED'], label='Installed Generation Capacity (MW)',color='black')
ax1.set_ylabel('Installed Generation Capacity (MW)')

ax2 = ax1.twinx()

# Bar plot for INTERTIE
ax2.bar(df['Year'], df['INTERTIE'], label='Intertie Capacity (MW)', color='pink', alpha=0.8)
ax2.set_ylabel('Intertie Capacity (MW)')

# Line plot for PRICE
ax3 = ax1.twinx()
ax3.plot(df['Year'], df['PRICE'], color='red', marker='o', linestyle='-', label='Price Difference (\$CAD kWh$^{-1}$)')
ax3.set_ylabel('Price difference between NE USA and Quebec (\$CAD kWh$^{-1}$)', fontsize=9)

ax3.spines['right'].set_position(('outward', 60))
ax3.yaxis.label.set_color('red')
ax3.tick_params(axis='y', colors='red')

handles1, labels1 = ax1.get_legend_handles_labels()
handles2, labels2 = ax2.get_legend_handles_labels()
handles3, labels3 = ax3.get_legend_handles_labels()
handles = handles1 + handles2 + handles3
labels = labels1 + labels2 + labels3
plt.legend(handles, labels, loc='upper left', frameon=False)

ax1.set_xlabel('Year')
plt.savefig("Figure_4.svg", format='svg', bbox_inches="tight")

plt.show()
