library(plyr)

dir<- "./UCI HAR Dataset"
featurePath <- paste(dir, "/features.txt", sep = "")
activityLabelPath <- paste(dir, "/activity_labels.txt", sep = "")
x_trainPath <- paste(dir, "/train/X_train.txt", sep = "")
y_trainPath <- paste(dir, "/train/y_train.txt", sep = "")
subject_trainPath <- paste(dir, "/train/subject_train.txt", sep = "")
x_test_file  <- paste(dir, "/test/X_test.txt", sep = "")
y_testPath  <- paste(dir, "/test/y_test.txt", sep = "")
subject_testPath <- paste(dir, "/test/subject_test.txt", sep = "")

features <- read.table(featurePath, colClasses = c("character"))
activity_labels <- read.table(activityLabelPath, col.names = c("ActivityId", "Activity"))
x_train <- read.table(x_trainPath)
y_train <- read.table(y_trainPath)
subject_train <- read.table(subject_trainPath)
x_test <- read.table(x_test_file)
y_test <- read.table(y_testPath)
subject_test <- read.table(subject_testPath)
trainData <- cbind(cbind(x_train, subject_train), y_train)
testData <- cbind(cbind(x_test, subject_test), y_test)
data <- rbind(trainData, testData)

labels <- rbind(rbind(features, c(562, "Subject")), c(563, "ActivityId"))[,2]
names(data) <- labels

meanStd <- data[,grepl("mean|std|Subject|ActivityId", names(data))]

meanStd <- join(meanStd, activity_labels, by = "ActivityId", match = "first")
meanStd <- meanStd[,-1]

names(meanStd) <- gsub('\\(|\\)',"",names(meanStd), perl = TRUE)
names(meanStd) <- make.names(names(meanStd))
names(meanStd) <- gsub('Acc',"Acceleration",names(meanStd))
names(meanStd) <- gsub('GyroJerk',"AngularAcceleration",names(meanStd))
names(meanStd) <- gsub('Gyro',"AngularSpeed",names(meanStd))
names(meanStd) <- gsub('Mag',"Magnitude",names(meanStd))
names(meanStd) <- gsub('^t',"TimeDomain.",names(meanStd))
names(meanStd) <- gsub('^f',"FrequencyDomain.",names(meanStd))
names(meanStd) <- gsub('\\.mean',".Mean",names(meanStd))
names(meanStd) <- gsub('\\.std',".StandardDeviation",names(meanStd))
names(meanStd) <- gsub('Freq\\.',"Frequency.",names(meanStd))
names(meanStd) <- gsub('Freq$',"Frequency",names(meanStd))


sensor_avg_by_act_sub = ddply(meanStd, c("Subject","Activity"), numcolwise(mean))
write.table(sensor_avg_by_act_sub, file = "tidyData.txt")
