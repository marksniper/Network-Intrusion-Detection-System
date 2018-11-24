library(caret)
kdd <- read.csv("train_KDD_without_dulicated.csv")

Charcol <- names(kdd[,sapply(kdd, is.factor)])
print(Charcol)
print(unique(kdd$result))#result of attack
print(unique(kdd$service))#network service on the destination, e.g., http, telnet, etc.
print(unique(kdd$flag))#normal or error status of the connection
print(unique(kdd$protocol_type))#type of the protocol, e.g. tcp, udp, etc.

#mean attack duraction
ggplot(data=kdd, aes(x=kdd$result, y=kdd$duration, fill = kdd$result)) + 
  geom_bar(stat = "summary", fun.y = "mean")+scale_x_discrete(name = "Attack")+
  scale_y_continuous("Duration")+labs(title="Mean attack duration", fill=("Attack\n") )

#median attack duraction
ggplot(data=kdd, aes(x=kdd$result, y=kdd$duration, fill = kdd$result)) + 
  geom_bar(stat = "summary", fun.y = "median")+scale_x_discrete(name = "Attack")+
  scale_y_continuous("Duration")+labs(title="Median attack duration", fill=("Attack\n") )

#average duration of attacks based on the type of protocol 
ggplot(data=kdd, aes(x=kdd$result, y=kdd$duration, fill = kdd$protocol_type)) + 
  geom_bar(stat = "summary", fun.y = "mean")+scale_x_discrete(name = "Attack")+
  scale_y_continuous("Duration")+ scale_fill_discrete(name = "Protocol type\n")+
  labs(title="Average duration of attacks based on the type of protocol" )

#Average duration of service based on the type of attack 
ggplot(data=kdd, aes(x=kdd$service, y=kdd$duration, fill = kdd$result)) + 
  geom_bar(stat = "summary", fun.y = "mean")+scale_x_discrete(name = "Service")+
  scale_y_continuous("Duration")+ scale_fill_discrete(name = "Attack")+
  theme(axis.text.x=element_text(angle=90,hjust=1))+
  labs(title="Average duration of attacks based on the type of protocol" )

#Individual observations using duration, attack and protocol type
p1 <- ggplot(kdd,aes(y = kdd$duration, x = kdd$result)) +
  geom_point()
p1 +  geom_point(aes(color=kdd$protocol_type))+
  labs(title="Duraction, attack and protocol type" , color ="Protocol type")+
  scale_x_discrete(name = "Attack")+
  scale_y_discrete("Duration")

#Service average based on the type of attack and protocol
ggplot(data=kdd, aes(x=kdd$service, y=kdd$result, fill = kdd$protocol_type)) + 
  geom_bar(stat = "summary", fun.y = "mean")+scale_x_discrete(name = "Service")+
  scale_y_discrete("Attack")+ scale_fill_discrete(name = "Protocol type\n")+
  theme(axis.text.x=element_text(angle=90,hjust=1))+
  labs(title="Average duration of attacks based on the type of protocol" )

#Flag analysis with type of attack and service
p1 <- ggplot(kdd,aes(y = kdd$flag, x = kdd$service)) +
  geom_point()
p1 +  geom_point(aes(color=kdd$result))+
  labs(title="Duraction, attack and protocol type" , color ="Attack\n")+
  scale_x_discrete(name = "Service")+
  scale_y_discrete("Falg")+ theme(axis.text.x=element_text(angle=90,hjust=1))

#type of service frequenc
quantity <- as.data.frame(table(kdd$protocol_type))
head(quantity)
bp<- ggplot(quantity, aes(x="", y=Freq, fill=Var1))+
  geom_bar(width = 1, stat = "identity")
pie <- bp +  coord_polar(theta = "y")+
  theme(axis.text = element_blank(),
        axis.ticks = element_blank(),
        panel.grid  = element_blank())+ scale_fill_discrete(name = "Protocol type")+ 
  labs(title = "Protcol type frequency")+
  labs(x = "", y = "");
pie
#show all character variables
p1 <- ggplot(kdd,aes(y = kdd$flag, x = kdd$service)) +
  geom_point()
p1 +  geom_point(aes(color=kdd$protocol_type, shape =kdd$result))+
  labs(title="all character variables\n\n" , color ="Protocol type",shape="Attack")+
  scale_x_discrete(name = "Service")+
  scale_y_discrete("Falg")+theme(axis.text.x=element_text(angle=90,hjust=1))
#show all occurrence flag
tcp_flag <- kdd[, 2:4]
tcp_flag <- tcp_flag[, -2]
table(tcp_flag)
#plot numeric values respect result values
kdd_numeric <- kdd[,-2]#remove protocol type
kdd_numeric <- kdd_numeric[,-2]#remove service
kdd_numeric <- kdd_numeric[,-2]#remove flag
str(kdd_numeric)
colNam <- colnames(kdd_numeric)
print(colNam)

qplot(duration,fill=result,data=kdd_numeric, bins = 30)

qplot(src_bytes,fill=result,data=kdd_numeric, bins = 30)

qplot(dst_bytes,fill=result,data=kdd_numeric, bins = 30)

qplot(land,fill=result,data=kdd_numeric, bins = 30)

qplot(wrong_fragment,fill=result,data=kdd_numeric, bins = 30)

qplot(urgent,fill=result,data=kdd_numeric, bins = 30)

qplot(hot,fill=result,data=kdd_numeric, bins = 30)

qplot(num_failed_logins,fill=result,data=kdd_numeric, bins = 30)

qplot(logged_in,fill=result,data=kdd_numeric, bins = 30)

qplot(num_compromised,fill=result,data=kdd_numeric, bins = 30)

qplot(root_shell,fill=result,data=kdd_numeric, bins = 30)

qplot(su_attempted,fill=result,data=kdd_numeric, bins = 30)

qplot(num_root,fill=result,data=kdd_numeric, bins = 30)

qplot(num_file_creations,fill=result,data=kdd_numeric, bins = 30)

qplot(num_shells,fill=result,data=kdd_numeric, bins = 30)

qplot(num_access_files,fill=result,data=kdd_numeric, bins = 30)

qplot(num_outbound_cmds,fill=result,data=kdd_numeric, bins = 30)

qplot(is_hot_login,fill=result,data=kdd_numeric, bins = 30)

qplot(is_guest_login,fill=result,data=kdd_numeric, bins = 30)

qplot(count,fill=result,data=kdd_numeric, bins = 30)

qplot(srv_count,fill=result,data=kdd_numeric, bins = 30)

qplot(serror_rate,fill=result,data=kdd_numeric, bins = 30)

qplot(srv_serror_rate,fill=result,data=kdd_numeric, bins = 30)

qplot(rerror_rate,fill=result,data=kdd_numeric, bins = 30)

qplot(srv_rerror_rate,fill=result,data=kdd_numeric, bins = 30)

qplot(same_srv_rate,fill=result,data=kdd_numeric, bins = 30)

qplot(diff_srv_rate,fill=result,data=kdd_numeric, bins = 30)

qplot(srv_diff_host_rate,fill=result,data=kdd_numeric, bins = 30)

qplot(dst_host_count,fill=result,data=kdd_numeric, bins = 30)

qplot(dst_host_srv_count,fill=result,data=kdd_numeric, bins = 30)

qplot(dst_host_same_srv_rate,fill=result,data=kdd_numeric, bins = 30)

qplot(dst_host_diff_srv_rate,fill=result,data=kdd_numeric, bins = 30)

qplot(dst_host_same_src_port_rate,fill=result,data=kdd_numeric, bins = 30)

qplot(dst_host_srv_diff_host_rate,fill=result,data=kdd_numeric, bins = 30)

qplot(dst_host_serror_rate,fill=result,data=kdd_numeric, bins = 30)

qplot(dst_host_srv_serror_rate,fill=result,data=kdd_numeric, bins = 30)

qplot(dst_host_rerror_rate,fill=result,data=kdd_numeric, bins = 30)

qplot(dst_host_srv_rerror_rate,fill=result,data=kdd_numeric, bins = 30)
