import pandas as pd
import sqlalchemy as sa


#Paste in your excelfile path down here (it should look like: r"C:\Users\Documents\your_data_sheet.xlsx")

df = pd.read_excel(r"Paste here your excelfile path", header = 0)
df.head() #Short check if the df is imported correctly


# Credentials to your local MySQL database connection

hostname="your_mysql_hostname" #if you are running your server locally, it should be: "localhost"
dbname="your_mysql_db_name"
uname="your_mysql_username" #Per default it's "root"
pwd="your_mysql_password"


#Define the newtablename for MySQL
tablename = "new_tablename"


# Create SQLAlchemy engine to connect to MySQL Database
engine = sa.create_engine("mysql+pymysql://{user}:{pw}@{host}/{db}"
                       .format(host=hostname, db=dbname, user=uname, pw=pwd))


# Convert dataframe to sql table                                   
df.to_sql(con=engine, name=tablename, if_exists='replace') #If a table with this name already exists, it will replace it