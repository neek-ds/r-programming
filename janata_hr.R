# to predict the probability of an enrollee to look for a new job.

#***********Load the Dataset**********************************

hrdata = read.csv(file.choose(),header = T)

#checking the structure of the data
head(hrdata)
str(hrdata)

#copy the data to another variable
hr_train = hrdata
str(hr_train)
head(hr_train)

#checking the summary of the data
summary(hr_train)


#checking for missing values in the data
sum(is.na(hr_train))

table(hr_train$gender)
#in this variable Other is a level we can use to replace the blank value with Other rather than 
#a level with highest mode value 
hr_train$gender[hr_train$gender=='']='Other'

#In a situation where we dont have a level named as Other we use to replace blank values with
#a level with highest frequency

table(hr_train$enrolled_university)
hr_train$enrolled_university[hr_train$enrolled_university=='']='no_enrollment'

table(hr_train$education_level)
dim(hr_train)
hr_train$education_level[hr_train$education_level=='']='Graduate'

#we r replacing the major discipline with other because it is one of the levels 
table(hr_train$major_discipline)
hr_train$major_discipline[hr_train$major_discipline=='']='Other'

str(hr_train)

table(hr_train$experience)
#since we dont have 'Other' as a well in this variable we replace the blank value with 
# a level which has highest frequency
hr_train$experience[hr_train$experience=='']='>20'

table(hr_train$company_size)
summary(hr_train$company_size)
levels(hr_train$company_size)[levels(hr_train$company_size)=='10/49']='10-49'
hr_train$company_size[hr_train$company_size=='']='50-99'

table(hr_train$company_type)
hr_train$company_type[hr_train$company_type=='']='Other'

table(hr_train$last_new_job)
#replace blanks with level with highest mode which is 1
hr_train$last_new_job[hr_train$last_new_job=='']='1'
#*********************************************************************************************


#******************************************************************
#class(hr_train)
#write.csv(hr_train,'E:/DS/Analytics/Hackathon/janata hack-hR/hr_train.csv',row.names = F)
#View(hr_train)

#checking for missing values in test data
hr_test=read.csv(file.choose(),header = T)
head(hr_test)
str(hr_test)

table(hr_test$gender)
hr_test$gender[hr_test$gender=='']='Other'

table(hr_test$enrolled_university)
hr_test$enrolled_university[hr_test$enrolled_university=='']='no_enrollment'

table(hr_test$education_level)
hr_test$education_level[hr_test$education_level=='']='Graduate'

table(hr_test$major_discipline)
hr_test$major_discipline[hr_test$major_discipline=='']='Other'

table(hr_test$experience)
hr_test$experience[hr_test$experience=='']='>20'

table(hr_test$company_size)
levels(hr_test$company_size)[levels(hr_test$company_size)=='10/49']='10-49'
hr_test$company_size[hr_test$company_size=='']='50-99'

table(hr_test$company_type)
hr_test$company_type[hr_test$company_type=='']='Other'

table(hr_test$last_new_job)
hr_test$last_new_job[hr_test$last_new_job=='']='1'

write.csv(hr_test,'E:/DS/Analytics/Hackathon/janata hack-hR/hr_test.csv',row.names = F)
View(hr_test)

#*****************************************************************************************

#Exploratory Data Analysis
str(hr_train)
hr_train=read.csv(file.choose(),header = T)
#checking for distribution of categorical variables
plot(hr_train$gender)
plot(hr_train$relevent_experience)
plot(hr_train$enrolled_university)
plot(hr_train$education_level)
plot(hr_train$major_discipline)
plot(hr_train$experience)
plot(hr_train$company_size)
plot(hr_train$company_type)
plot(hr_train$last_new_job)
hist(hr_train$training_hours)
boxplot(hr_train$training_hours)
#training hours variable has outliers and it is right skewed data, we can take the log of the variable
#to negate use of outliers
#hr_train$one=hr_train$training_hours
#boxplot(hr_train$one)
#hr_train$one=log(hr_train$one)
#boxplot(hr_train$one)

library(car)
library(carData)
library(caret)
library(lattice)
library(ggplot2)

hr_train$training_hours=log(hr_train$training_hours)
boxplot(hr_train$training_hours)
hist(hr_train$training_hours)

#to check correlation between categorical variables we will use cramer's v rule
str(hr_train)

library(GoodmanKruskal)
varset = c('city','gender','relevent_experience','enrolled_university','education_level',
           'major_discipline','experience','company_size','company_type','last_new_job')
hr2=subset(hr_train,select = varset)
gkmat2=GKtauDataframe(hr2)
plot(gkmat2)

#since the target variable is in the form of probability we will convert target variable to 
#factors

#checking important variables for model building
#hr_mod1 = glm(target~.,data=hr_train,family = 'binomial')
#print(hr_mod1)
#summary(hr_mod1)
#Degrees of Freedom: 18358 Total (i.e. Null);  18182 Residual
#Null Deviance:	    14330 
#Residual Deviance: 13450 	AIC: 13800

#var2 = subset(hr_train,select = c(-city))
#mod_2=glm(target~.,data = var2,family = 'binomial')
#print(mod_2)
#summary(mod_2)

#Degrees of Freedom: 18358 Total (i.e. Null);  18303 Residual
#Null Deviance:	    14330 
#Residual Deviance: 13670 	AIC: 13780

# with p value results for variables it can be seen thaty city and city development index is highly correlated
#so if we use one variable instead of 2 that will reduce multicollinearity

var3=subset(hr_train,select = c(-city_development_index))
mod_3=glm(target~.,data=var3,family='binomial')
summary(mod_3)

#Null deviance: 14332  on 18358  degrees of freedom
#Residual deviance: 13450  on 18182  degrees of freedom
#AIC: 13804
#var44=subset(hr_train,select = c(-city,-city_development_index))
#mod4=glm(target~.,data=var44,family='binomial')
#summary(mod4)

#Null deviance: 14332  on 18358  degrees of freedom
#Residual deviance: 13841  on 18304  degrees of freedom
#AIC: 13951
colnames(hr_train)
#var5=subset(hr_train,select = c(-training_hours,-city_development_index))
#mod5=glm(target~.,data=var5,family='binomial')
#summary(mod5)

#since city and city development index is correlated we r using only city to avoid multicollinearity
#as we have seen keeping both variables in model building city_development_index results in NA 
#values in summary output moreover the null and residual deviance values doesnt change much
# when we exclude city and keep city development index

#but when city is excluded the difference between null and residual deviance is not much
#but when city_development_index is excluded the residual deviance is reduced
train_hr = var3
dim(train_hr)

#converting the target variable into factor
train_hr$target = as.factor(train_hr$target)
hr_model=glm(target~.,data=train_hr,family='binomial')
summary(hr_model)

#1, means looking for a job change
#0, means not looking for a job change

#finding the probabilities
train_hr$prob=round(fitted(hr_model),2)
head(train_hr$prob)
#View(train_hr$prob)

#breaking the probabilities into 0's and 1's
#train_hr$predictedjob = ifelse(train_hr$prob > 0.3,1,0)
#class(train_hr$predictedjob)
#train_hr$predictedjob=as.factor(train_hr$predictedjob)
#head(train_hr$predictedjob)
head(train_hr$target)
train_hr$pred1=ifelse(train_hr$prob>0.5,1,0)
class(train_hr$pred1)
train_hr$pred1=as.factor(train_hr$pred1)

class(train_hr$target)
#finding the accuracy of the model using AUC-ROC curve
library(ROCR)
library(gplots)
pred=prediction(train_hr$prob,train_hr$target)
pred
perform=performance(pred,'tpr','fpr')
perform
# prediction will calculate probability on it own seeing the cutoff value
# takes input from prediction , performance function calculate tpr and fpr

plot(perform,colorize = T,print.cutoffs.at=seq(0.1,by=0.1))

#creating table for confusion matrix
#classic_table=table(train_hr$target,train_hr$predictedjob)
#classic_table

#Accuracy
#(15403+262)/(15403+262+531+2163)
#[1] 0.85326

#sensitivity
#262/(262+531) #1 identified as 1
#[1] 0.3303909
#specificity
#15403/(15403+2163) #0 identified as 0
#[1] 0.8768644


#accu = performance(pred,"auc")
#(accu@y.values)
#[1] 0.6798148

#with cut off value being 0.3 the accuracy of the model is ~68%

#****************************************************************

#lets check the accuracy of the model with cutoff point as 0.5
tab1=table(train_hr$target,train_hr$pred1)
tab1

#Accuracy
(15921+16)/(15921+16+13+2409) #[1] 0.8680756

#sensitivity 1 identified as 1
16/(16+13)#[1] 0.5517241

#specificity
15921/(15921+2409) #[1] 0.8685761

#Area under the curve - [1] 0.6840505
accu = performance(pred,"auc")
(accu@y.values)

#with cutoff point 0.3 the accuracy of classification from confusion matrix is 85% and sensitivity
# 33% and specificity 87%

#with cutoff point 0.5 the accuracy of classification is 86% and sensitivity is 55% and 
#specificity 86%

#model accuracy - [1] [1] 0.6840505 =68.3%

#********************************************************************************************

#Now testing the model with the test data

hr_test = read.csv(file.choose(),header = T)
head(hr_test)
dim(hr_test)

#check for missing values
colSums(is.na(hr_test))

#As per the question the
#Note that the test data is further randomly divided into Public (40%) and Private (60%) data.
# Your initial responses will be checked and scored on the Public data.

#finding the predictions on test data
hr_pred = round(predict(hr_model,data=hr_test,type = 'response'),2)
head(hr_pred)

dim(hr_pred)
res = ifelse(hr_pred > 0.5,1,0)


#now concatenating the ID and target column together

submission = data.frame(enrollee_id=1:length(hr_pred),res=res)
write.csv(submission,file = 'E:/DS/Analytics/Hackathon/janata hack-hR/finalsubmission.csv',row.names = F)