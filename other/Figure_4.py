import matplotlib.pyplot as plt
import pandas as pd
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
ax3.plot(df['Year'], df['PRICE'], color='red', marker='o', linestyle='-', label='Price Difference ($CAD/kWh)')
ax3.set_ylabel('Price difference between U.S. and Quebec ($CAD/kWh)')

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
