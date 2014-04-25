## Read train and test data ##

x_train<-read.table("train/X_train.txt")
x_test<-read.table("test/X_test.txt")

## Append the two data tables

x_train_test<-rbind(x_train, x_test)
rm(x_train, x_test)

## Read and append in the same way the subject ids and activity ids

subject_train<-read.table("train/subject_train.txt")
subject_test<-read.table("test/subject_test.txt")
subject_train_test<-rbind(subject_train, subject_test)

activity_train<-read.table("train/y_train.txt")
activity_test<-read.table("test/y_test.txt")
activity_train_test<-rbind(activity_train,activity_test)

rm(subject_train, subject_test, activity_train, activity_test)

## Add correspondent subject ids and activity ids to train and test data

x_subject_activity<-cbind(subject_train_test,activity_train_test,x_train_test)

rm(subject_train_test, activity_train_test, x_train_test)

## Read the feature names and apply them to the combined data

feature_names<-read.table("features.txt")
colnames(x_subject_activity)<-append(as.vector(feature_names[,2]),c("subject_id","activity_id"),after=0)

rm(feature_names)

## Filter to keep just the mean and standard deviation measures
## (as well as the subject and activity ids)

x_filtered<-x_subject_activity[,grepl("subject_id|activity_id|mean|std",colnames(x_subject_activity))]
rm(x_subject_activity)

## Read the activity descriptive names and add descriptive names
## to its columns. activity_id should have the same name that on the main dataset
## in order to be able to join them toghether

activity_names<-read.table("activity_labels.txt")
colnames(activity_names)<-c("activity_id","activity_label")

## Join the activity names data with the filtered data using
## the activity ids on both datasets

x_labeled<-arrange(join(x_filtered,activity_names),activity_id)
rm(x_filtered, activity_names)

## Calculate the mean of every variable grouped by Activity and Subject id

summ_means <-aggregate.data.frame(x_labeled, 
              by=list(Subject = x_labeled$subject_id, Activity=x_labeled$activity_label), 
              mean)

## Drop redundant variables and create .txt file to be uploaded

drop_vars <- c("Subject","activity_label")
tidy_means <- summ_means[,!(names(summ_means) %in% drop_vars)]
rm(x_labeled, summ_means, drop_vars)

write.table(tidy_means, file = "tiny_means_dataset.txt")
