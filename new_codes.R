head.to.head = function(by=20,
                        df.H,
                        df.Y,
                        LG='LG', 
                        C='C', 
                        path = getwd(),
                        site = "MUNI",
                        env="env.mean",
                        gid="gid",
                        unidade = 'bags/ha',
                        y = "PROD",
                        type='Hibrido',
                        Regiao='Regiao', full=T, smoot=F){
  #'---------------------------------------------------------------#
  df.t        = df.H[,c(LG,C)]
  df.y        = df.Y[,c(env,site,gid,y)]
  names(df.y) = c("env","site","gid","value")
  #'---------------------------------------------------------------#
  
  x.lab = paste0("Yield Trial Mean (",unidade,")")
  y.lab = paste0("Expected Mean (",unidade,")")
  
  
  # x.lab = paste0("\nEnvironmental Mean (",unidade,")")
  #y.lab = paste0("Expected Mean (",unidade,")\n")
  
  try(for(K in 1:nrow(df.t)){
    LG   = as.character(df.t$LG[K])
    C    = as.character(df.t$C[K])
    nome = paste(Regiao,LG,"x",C,sep=" ")
    
    cat(paste("Figura ",nome,"\n",sep=""))
    
    J   =  droplevels(df.y[df.y$gid%in%c(LG,C),])
    lim = round(seq(0.98*min(J$value,na.rm=T),max(J$value,na.rm=T)*1.01,by=by),0)
    end = lim[length(lim)]
    
    
    a  <- droplevels(df.y[df.y$gid%in%c(LG,C),])
    a  <- acast(a,site~gid,fun.aggregate = mean,value.var = "value")
    a  <- a[complete.cases(a),]
    EC <- row.names(a)
    DF <- droplevels(J[J$site %in% EC,])
    
    DF$gid <- factor(DF$gid, levels=c(C,LG))
    p1  = ggplot(DF, aes(x=env,y=value,colour=gid))+
      stat_smooth(data=DF, aes(x=env,y=value,fill=gid,colour=gid),
                  se=smoot,method="lm",fullrange = full,size=1.5,alpha=0.05)+
      geom_point(size=1.5)+
      xlab(x.lab)+ylab(y.lab)+
      scale_fill_manual(values=c("gray35","darkgreen"))+ 
      theme_classic()+ 
      geom_text(data=DF,aes(x = env, y = value, label = site), vjust = 2, size = 2.5)+
      scale_x_continuous(limits = c(lim[1],lim[length(lim)]),breaks=lim)+
      scale_y_continuous(limits = c(lim[1],lim[length(lim)]),breaks=lim)+
      theme(axis.line = element_line(colour = "black", size = 1, linetype = "solid"),
            legend.position = c(.2,.92),
            legend.text = element_text(size=8))+
      scale_colour_manual(values=c("gray35","darkgreen"))+graphs+
      labs(fill=type,colour=type)+
      theme(legend.title = element_text(size=10,face='bold'),
            panel.grid.major = element_blank(),panel.grid.minor = element_blank(),
            panel.background = element_rect(fill = "white",
                                            colour = "white",
                                            size = 0.5, linetype = "solid"))
    
    
    a  <- acast(droplevels(DF[DF$gid%in%c(LG,C),]),site~gid,fun.aggregate = mean,value.var = "value")
    
    dIm <- nrow(a)
    
    a = data.frame(Var1 = c(C,LG),
                   value=c(sum(colnames(a)[apply(a, 1, which.max)] %in% C),
                           nrow(a)-sum(colnames(a)[apply(a, 1, which.max)] %in% C)))
    
    a$Var1 <- factor( a$Var1,levels= c(C,LG)) 
    
    p2=ggplot(data=a,aes(x=Var1,y=value,fill=Var1))+
      xlab("")+ylab("")+
      geom_bar(position = "stack",stat = "identity",colour="white",size=0.7,
               width = .95)+
      theme_classic()+
      ggtitle(label = paste0("Total Wins (over ", dIm,' trials)'))+
      geom_text(aes(label=value), vjust=-.3, face="bold",color="black", size=5)+
      theme(legend.position = "none",
            #  axis.line = element_line(colour = "black", 
            #           size = 1, linetype = "solid"))+
            axis.line = element_blank())+
      scale_fill_manual(values= c("gray35","darkgreen"))+
      scale_colour_manual(values=c("gray35","darkgreen"))+graphs+
      theme(axis.text.y = element_blank(),
            title = element_text(size=14,face='bold',colour='black'),
            panel.background = element_rect(fill = "white",
                                            colour = "white",
                                            size = 0.5, linetype = "solid"),
            panel.grid.major = element_blank(),panel.grid.minor = element_blank())
    
    p3=annotate_figure(ggarrange(p1,p2,ncol=2,widths = c(1.8,.8),align = 'h',common.legend = F))
    #  b=annotate_figure(p3,
    #         top = text_grob(Regiao, 
    #                color = "darkgreen", face = "bold", size = 18))
    
    b = p3
    ggsave(filename= paste(nome,".png",sep=""),dpi = 300, path = path,plot = b,width = 14,height = 5.1)
  })
}


ECP = function(y){
  P_Ecdf  = Ecdf(y,datadensity = 'none',what = "1-F",pl=F)
  output = data.frame(value=P_Ecdf$x, prob=as.vector((P_Ecdf$y)*100))
  return(output)
}

FW.out = function(y, gid, env, method = "OLS",scale=TRUE, to = c(0.5,2)){
  fit = FW(y=y,VAR = gid,ENV = env,method = method)
  out = data.frame(g = fit$mu+fit$g, b = fit$b)
  if(scale == TRUE){out$b = rescale(out$b,to=to)}
  names(out) = c("g","b")
  return(list(acc=cor(fit$y,fit$yhat),adp=out))
}

#library(devtools)
#install_github('lian0090/FW')

require(Hmisc)
require(FW)
