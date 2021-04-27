trait.by.trait = function(by1=15,
                        by2=0.01,
                        df.Y,
                        path = getwd(),
                        site = "MUNI",
                        t1 = 'PROD',
                        t2 = 'UC',
                        gid="gid",
                        n1 = 'Rendimento',
                        n2 = 'Umidade de Colheita',
                        u1 = 'sc/ha',
                        u2 = '%',
                        type='Hibrido',
                        Regiao='Região', full=T, smoot=F){
  
  #'---------------------------------------------------------------#
  df.y        = df.Y[,c(t1,t2,gid,Regiao)]
  names(df.y) = c("t1","t2","gid",'Ensaio')
  #'---------------------------------------------------------------#
  #'
  
  for(j in 1:nlevels(df.y$Ensaio)){
    ensaio = levels(df.y$Ensaio)[j]
    J = droplevels(subset(df.y,Ensaio == ensaio))
    J$gid= droplevels(J$gid)
    lim.y = round(seq(0.9*min(J$t1,na.rm=T),max(J$t1,na.rm=T)*1.1,length.out = 5),0)
    end.y = lim.y[length(lim.y)]
    
    lim.x = round(seq(min(J$t2,na.rm=T)*0.9,
                      max(J$t2,na.rm=T)*1.1,length.out = 4),2)
    end.x = lim.x[length(lim.x)]
    
    nome = paste(ensaio,' ',n1,' x ',n2,sep="")
    cat(paste0(nome),'\n')
    require(ggrepel)
    p1=ggplot(J, aes(x=t2,y= t1,colour=gid))+
      geom_hline(yintercept = mean(J$t1,na.rm=T),size=.2,linetype='dashed')+
      geom_vline(xintercept = mean(J$t2,na.rm=T),size=.2,linetype='dashed')+
      geom_point() + facet_grid(~Ensaio)+
      xlab(paste0('\n',n2,' (',u2,')'))+ylab(paste0(n1,' (',u1,')\n'))+
      # scale_fill_manual(values=c("royalblue","red3"))+ 
      theme_classic()+
      geom_text_repel(aes(x=t2,y= t1, label = gid), vjust = 2, 
                size = 2.5)+
      scale_x_continuous(limits = c(lim.x[1],lim.x[length(lim.x)]),
                         breaks=lim.x,labels = scales::percent)+
      scale_y_continuous(limits = c(lim.y[1],lim.y[length(lim.y)]),
                         breaks=lim.y,sec.axis = dup_axis())+
      theme(legend.position = 'none',strip.background = element_rect(colour='red'))+
      #scale_colour_manual(values=c("royalblue","red3"))+
      labs(fill=type,colour=type)+graphs+
      theme(axis.title.y.right  = element_blank(),
        panel.background = element_rect(fill = "gray98",
                                        colour = "gray98",
                                        size = 0.5, linetype = "solid",)
      )
    
    
    ggsave(filename= paste(nome,' ',n1,' x ',n2,".png",sep=""), path = path,plot = p1,width = 5,height = 4)
    
  }
}
  
graphs=   theme(plot.title = element_text(size = 15, hjust=0.5,
                                          face = "bold",colour="red3"),
                text = element_text(size = 12, family = "Arial"),
                axis.title = element_text(face="bold", colour="red3"),
                axis.text.x=element_text(size = 11))+
  theme(strip.text = element_text(face="bold", size=10,lineheight=5.0,colour="white"),
        strip.background = element_rect(fill="red3", colour="black",size=1))




head.to.head = function(by=20,
                        df.H,
                        df.Y,
                        LG='LG', 
                        C='C', 
                        path = getwd(),
                        site = "MUNI",
                        env="env.mean",
                        gid="gid",
                        unidade = 'sc/ha',
                        y = "PROD",
                        type='Hibrido',
                        Regiao='Regiao', full=T, smoot=F){
  #'---------------------------------------------------------------#
  df.t        = df.H[,c(LG,C)]
  df.y        = df.Y[,c(env,site,gid,y)]
  names(df.y) = c("env","site","gid","value")
  #'---------------------------------------------------------------#
  
  x.lab = paste0("\nMédia Ambiental (",unidade,")")
  y.lab = paste0("Média do ",type,"(",unidade,")\n")

  try(for(K in 1:nrow(df.t)){
    LG   = as.character(df.t$LG[K])
    C    = as.character(df.t$C[K])
    nome = paste(Regiao,LG,"x",C,sep=" ")
    
    cat(paste("Figura ",nome,"\n",sep=""))
    
    J   =  df.y[df.y$gid%in%c(LG,C),]
    lim = round(seq(0.9*min(J$value,na.rm=T),max(J$value,na.rm=T)*1.1,by=20),0)
    end = lim[length(lim)]
    
    
    a  <- droplevels(df.y[df.y$gid%in%c(LG,C),])
    a  <- acast(a,site~gid,fun.aggregate = mean,value.var = "value")
    a  <- a[complete.cases(a),]
    EC <- row.names(a)
    DF <- droplevels(J[J$site %in% EC,])
    
    p1  = ggplot(DF, aes(x=env,y=value,colour=gid))+
          stat_smooth(data=DF, aes(x=env,y=value,fill=gid,colour=gid),se=smoot,method="lm",fullrange = full,size=1)+
      geom_point(size=1.1)+
      xlab(x.lab)+ylab(y.lab)+
      scale_fill_manual(values=c("royalblue","red3"))+ 
      theme_minimal()+ 
      geom_text(data=DF,aes(x = env, y = value, label = site), vjust = 2, size = 2)+
      scale_x_continuous(limits = c(lim[1],lim[length(lim)]),breaks=lim)+
      scale_y_continuous(limits = c(lim[1],lim[length(lim)]),breaks=lim)+
      theme(axis.line = element_line(colour = "black", size = 1, linetype = "solid"),legend.position = c(.15,.90))+
      scale_colour_manual(values=c("royalblue","red3"))+graphs+ labs(fill=type,colour=type)
    

    a  <- acast(droplevels(DF[DF$gid%in%c(LG,C),]),site~gid,fun.aggregate = mean,value.var = "value")

    
    a = data.frame(Var1 = c(C,LG),
                   value=c(sum(colnames(a)[apply(a, 1, which.max)] %in% C),
                           nrow(a)-sum(colnames(a)[apply(a, 1, which.max)] %in% C)))
    
    p2=ggplot(data=a,aes(x=Var1,y=value,fill=Var1))+
      xlab("\n")+ylab("Número de Vitórias")+
      geom_bar(position = "stack",stat = "identity",colour="black",
               width = .96)+
      theme_minimal()+
      theme(legend.position = "none",
            axis.line = element_line(colour = "black", 
                                     size = 1, linetype = "solid"))+
      scale_fill_manual(values= c("royalblue","red3"))+
      scale_colour_manual(values=c("royalblue","red3"))+graphs
    
    p3=ggarrange(p1,p2,ncol=2,widths = c(1.8,.8),common.legend = F)
    b=annotate_figure(p3,
                      top = text_grob(nome, 
                                      color = "red3", face = "bold", size = 19))
    
    
    ggsave(filename= paste(nome,".png",sep=""), path = path,plot = b,width = 11.6,height = 5.6)
  })
}





