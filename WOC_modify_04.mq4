//+------------------------------------------------------------------+
//|                                                WOC_modify_04.mq4 |
//|                                                                  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright ""
#include <stderror.mqh>
#include <stdlib.mqh>

extern int     StopLoss       =  6;  //начальный стоплосс
//extern int     TakeProfit     =  6;  //тейк
extern int     TrSt           =  6;  //Трал
extern int     Speed          =  5;
extern double  timeSpeed      =  3; 
//extern 
int     Dig;// = 4;// 2 for jpy 4 for other crosses "Digits 2 = jpy, 4 = other crosses"
extern double Lots = 0.1;
extern double MaxLot = 0.1;
extern bool   LotsOptimized = TRUE;
extern int    Risk = 20;
extern int Magic = 20080829;



double         sl,tp,Point_;
datetime       nextTime;
int            ticket, cnt, total, lastBars;
int            Virtual_control,up, down, TimeSpeedUp, TimeSpeedDown;
bool           TimBoolUp,TimBoolDown, OrderSal;
double         priceUp, priceDown;


int              PipMultiplier=1;

double Virtual_stop_buy1,Virtual_stop_sell1;
bool createline_buy1 = false;  
bool createline_sell1 = false;  
string line_buy1 = "Virt_stop_buy_1"; 
string line_sell1="Virt_stop_sell_1"; 
double Virtual_buy_profit,Virtual_sell_profit;
bool createline_buy_profit = false;  
bool createline_sell_profit = false;  
string line_buy_profit = "Virt_buy_profit"; 
string line_sell_profit="Virt_sell_profit"; 
//---------------------------------------------------------------------------
void openOrders()
{  
   int try;
   int minstop= MarketInfo(Symbol(),MODE_STOPLEVEL);
   Virtual_control=0;
  
   if(up < down)
   {
      Print("Параметр вниз - удовлетворяет условию");
      if(TimeCurrent() - TimeSpeedDown <= timeSpeed)
      {           
         Print("Параметр ВРЕМЯ - удовлетворяет условию"); 
         RefreshRates(); 
         for(try = 1; try <= 2; try++)
         {          
           ticket=OrderSend(Symbol(),OP_SELL,GetLots(),Bid,10,0,0 ,"",Magic,0,Red);
           if(ticket>0){
              if(StopLoss*PipMultiplier>minstop)//||TakeProfit*PipMultiplier> minstop)
                 if(OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)){
                   while (!IsTradeAllowed()) Sleep(500);  RefreshRates();
     Print("Ставим физические уровни стопов открытому селл");
     sl=0;if(StopLoss*PipMultiplier >minstop)sl=NormalizeDouble(Ask + StopLoss*Point*PipMultiplier, Digits);
     //tp=0;if(TakeProfit*PipMultiplier>minstop)tp=NormalizeDouble(Bid - TakeProfit*Point*PipMultiplier, Digits);
     Print(" Уровень стопа ", sl );
     if(!OrderModify(OrderTicket(),OrderOpenPrice(),sl,0,0, Red))Virtual_control=1;break;}}
          else 
            {  Print("Ошибка ", ErrorDescription(GetLastError()));
               Print("Невозможно открыть ордер, попытка ", try);
               Sleep(1000);
               RefreshRates();
            }
            
         }
      }   
   }
    else 
   {  
      Print("Параметр вверх - удовлетворяет условию");
      if(TimeCurrent() - TimeSpeedUp <= timeSpeed)
      {           
         Print("Параметр ВРЕМЯ - удовлетворяет условию"); 
         RefreshRates();    
         for(try = 1; try <= 2; try++)
         {                    
          ticket=OrderSend(Symbol(),OP_BUY,GetLots(),Ask,10,0,0, "", Magic, 0, Green);
          if(ticket>0){
              if(StopLoss*PipMultiplier>minstop)//||TakeProfit*PipMultiplier> minstop)
                 if(OrderSelect(ticket, SELECT_BY_TICKET, MODE_TRADES)){
                   while (!IsTradeAllowed()) Sleep(500);  RefreshRates();
      Print("Ставим физические уровни стопов открытому бай");
      sl=0;if(StopLoss*PipMultiplier >minstop)sl=NormalizeDouble(Bid - StopLoss*Point*PipMultiplier, Digits);
     // tp=0;if(TakeProfit*PipMultiplier >minstop)tp=NormalizeDouble(Ask + TakeProfit*Point*PipMultiplier, Digits);
      Print(" Уровень стопа ", sl );
      if(!OrderModify(OrderTicket(),OrderOpenPrice(),sl,0,0, Green))Virtual_control=1;break;}}
          else
           {  Print("Ошибка ", ErrorDescription(GetLastError()));
               Print("Невозможно открыть ордер, попытка ", try);
               Sleep(1000);
               RefreshRates();
            } 
            
         }
                
      }   
   }    
   priceUp   = 0;
   priceDown = 0;
   up        = 0;
   down      = 0;
   TimBoolUp = false;
   TimBoolDown = false;
   TimeSpeedUp = 0;
   TimeSpeedDown = 0;       
}
//----------------------------------

int init()
{
 //  Magic = Get.Magic();
 if (Digits==3 || Digits==5)
         PipMultiplier=10;
   else  PipMultiplier=1;
   return(0);
}
//----------------------------------
int deinit()
{
   return(0);
}
/////////////////////////////////////
int start()
{   
  
   total = OrdersTotal();
   int   i, currentSymbolOrderPos = -1;
      
   for (i = 0; i < total; i++)   
   {
      OrderSelect(i, SELECT_BY_POS, MODE_TRADES);
      if (OrderSymbol() == Symbol() &&  OrderMagicNumber()==Magic)
      {
         currentSymbolOrderPos =i;
         break;
      }
   }
   
    if (currentSymbolOrderPos < 0)
   {      
      if(Virtual_stop_buy1>0 || Virtual_stop_sell1>0)
        {Virtual_stop_buy1=0;Virtual_stop_sell1=0;DeletAll_line();}  
     // if(Virtual_sell_profit>0 || Virtual_buy_profit>0)
     //   {Virtual_sell_profit=0;Virtual_buy_profit=0;Delet_line_profit();}
   Dig=4;
   if (Digits<4 ) Dig=2;
   double ask = StrToDouble(DoubleToStr(Ask,Dig));   
   double bid = StrToDouble(DoubleToStr(Bid,Dig));
 
    
    if(priceUp < ask)
      {
         up = up + 1;
         priceUp = ask;
         if(TimBoolUp == false)
         {
            TimeSpeedUp = TimeCurrent();
            TimBoolUp = true;
         }   
      }
   else
      {
        priceUp = 0;
       
        up      = 0;
        TimBoolUp = false;
        TimeSpeedUp = 0;
      }
   
      if(priceDown > ask)
      {
         down = down + 1;
         priceDown = ask;
         if(TimBoolDown == false)
         {
            TimeSpeedDown = TimeCurrent();
            TimBoolDown = true;
         }   
      }
      else
      {
         priceDown = 0;
         down      = 0;
         TimBoolDown = false;
         TimeSpeedDown = 0;   
      }
 
      if(up == Speed || down == Speed)
      {          
            openOrders();                  
      }   
   
         
      if(priceUp == 0)
      {
         priceUp   = ask;         
      }
      if(priceDown == 0)
      {        
         priceDown = ask;
      }
   }   
else // Есть открытый ордер по текущему символу
   {
     TrailingStop();
   }   
   return(0);
}
//-----------------------------------------------------------------------
double GetLots() 
{
   int dig = MarketInfo(OrderSymbol(), MODE_DIGITS);//Get digits size
   double MinlotTmp = MarketInfo(Symbol(), MODE_MINLOT); //What's the minimum possible lot size
   double MaxlotTmp = MarketInfo(Symbol(), MODE_MAXLOT); //What's the maximum possible lot size   
   double Leverage = AccountLeverage(); //How much can you use depending on your account ballance and what the broker allowes   
   double LotSize = MarketInfo(Symbol(), MODE_LOTSIZE); //What is the allowed lot size
   
   double lotsTmp = MathMin(MaxlotTmp, MathMax(MinlotTmp, Lots));   
   if (LotsOptimized && Risk > 0.0 && AccountFreeMargin() > Ask * lotsTmp * LotSize / Leverage) lotsTmp = NormalizeDouble(AccountFreeMargin() * Risk / LotSize, dig);
   else lotsTmp = MinlotTmp;
   
   lotsTmp = MathMax(MinlotTmp, MathMin(MaxlotTmp, NormalizeDouble(lotsTmp / MinlotTmp, 0) * MinlotTmp));
   //lotsTmp = NormalizeDouble(lotsTmp / Max_BuySell, LotDecimal);
   
   if (lotsTmp > MaxLot) lotsTmp = MaxLot;
   //if (AccountFreeMargin() < Ask * lotsTmp * LotSize / Leverage) {
      //Print("Low Account Balance. Lots = ", lotsTmp, " , Free Margin = ", AccountFreeMargin());
      //Comment("Low Account Balance. Lots = ", lotsTmp, " , Free Margin = ", AccountFreeMargin());
     // return;
   return (lotsTmp);
}

//-------------------------------------------------------------------------
void TrailingStop(){
double bid,ask,op,stop,mod_stop;int magic;
double p = MarketInfo(Symbol(),MODE_POINT); int tral=1;
int minstop= MarketInfo(Symbol(),MODE_STOPLEVEL);
if(TrSt*PipMultiplier <= minstop )tral=-1;//переход на виртуальный 
//--------                        
   for (int i=OrdersTotal()-1; i>=0; i--){ 
      if (OrderSelect(i,SELECT_BY_POS,MODE_TRADES)==false) break; 
      if (OrderSymbol()!=Symbol()) continue;
      magic=OrderMagicNumber();
      if(magic!=Magic ) continue;
      //Print("Попытка тралить ордер № ", OrderTicket(), "  с магиком  ",magic);
      if(OrderType()==OP_BUY){

if(StopLoss*PipMultiplier<= minstop || Virtual_control==1){
   if(OrderStopLoss()==0 ) 
     if(Virtual_stop_buy1 ==0)
       {Virtual_stop_buy1 = OrderOpenPrice() - StopLoss*PipMultiplier*p;
                                                  Print("Рисуем линию stop_buy1 на уровне ",Virtual_stop_buy1);
                                                 Set_line_buy1(Virtual_stop_buy1, Green);}
   if(OrderOpenPrice()-Ask>=StopLoss*PipMultiplier*p)
      OrderClose(OrderTicket(),OrderLots(),Bid,5*PipMultiplier,Blue);}
/*
if(TakeProfit*PipMultiplier<= minstop){
   if(Virtual_buy_profit ==0)
   if(OrderTakeProfit()==0 || Virtual_control==1) 
     {Virtual_buy_profit = OrderOpenPrice() + TakeProfit*PipMultiplier*p;
                                                  Print("Рисуем линию profit_buy1 на уровне ",Virtual_buy_profit);
                                                 Set_line_buy_profit(Virtual_buy_profit, Green);}

   if(Bid-OrderOpenPrice()>=TakeProfit*PipMultiplier*p)
      OrderClose(OrderTicket(),OrderLots(),Bid,5*PipMultiplier,Blue);}
*/
if(tral==-1) {//виртуальный трейлинг бай ордера 
   op=OrderOpenPrice(); 
   while (!IsTradeAllowed()) Sleep(500);  RefreshRates();  bid = Bid;
       if(Virtual_stop_buy1==0){
         if(bid- TrSt*PipMultiplier*p > op) Virtual_stop_buy1 = bid- TrSt*PipMultiplier*p;//начало
         Print("Рисуем линию stop_buy1 на уровне ",Virtual_stop_buy1);
                              Set_line_buy1(Virtual_stop_buy1, Green);}
     if(Virtual_stop_buy1>0){
        if(bid<Virtual_stop_buy1)
          {if(OrderClose(OrderTicket(),OrderLots(),Bid,5*PipMultiplier,Blue)){ DeletAll_line();break;}}
        if(bid- TrSt*PipMultiplier*p > op && bid- TrSt*PipMultiplier*p > Virtual_stop_buy1) 
          {Virtual_stop_buy1 = bid- TrSt*PipMultiplier*p;Set_line_buy1(Virtual_stop_buy1, Green);}}
   } 
//---
if( tral==1){// сейчас будем реально тралить бай ордер
  op=OrderOpenPrice();stop=OrderStopLoss(); mod_stop=stop;
  while (!IsTradeAllowed()) Sleep(500);  RefreshRates();   bid = Bid;
  if(bid- TrSt*PipMultiplier*p > op) mod_stop = bid- TrSt*PipMultiplier*p;//трал
  if(mod_stop>stop  && mod_stop > op && bid- mod_stop > minstop*p)
  if(!OrderModify(OrderTicket(),op,NormalizeDouble(mod_stop,Digits), OrderTakeProfit(),0))
      Print("Не получилось переставить стоп, ошибка  " ,GetLastError());
   else {Virtual_stop_buy1=0;Virtual_stop_sell1=0;DeletAll_line();}}
         
    }
//-----------------------------
   if(OrderType()==OP_SELL){
    if(StopLoss*PipMultiplier<= minstop || Virtual_control==1){
    
      if(OrderStopLoss()==0)
      if(Virtual_stop_sell1 ==0)
        {Virtual_stop_sell1 = OrderOpenPrice() + StopLoss*PipMultiplier*p;
                                                  Print("Рисуем линию stop_sell1 на уровне ",Virtual_stop_sell1);
                                                 Set_line_sell1(Virtual_stop_sell1, Red);}
    if(Bid-OrderOpenPrice()>=StopLoss*PipMultiplier*p)
      OrderClose(OrderTicket(),OrderLots(),Ask,5*PipMultiplier,Red);}
/*   
   if(TakeProfit*PipMultiplier<= minstop || Virtual_control==1){
     if(Virtual_sell_profit ==0)
     if(OrderTakeProfit()==0) 
       {Virtual_sell_profit = OrderOpenPrice() - TakeProfit*PipMultiplier*p;
                                                  Print("Рисуем линию profit_sell на уровне ",Virtual_sell_profit);
                                                 Set_line_sell_profit(Virtual_sell_profit, Red);}
     if(OrderOpenPrice()-Ask>=TakeProfit*PipMultiplier*p)
      OrderClose(OrderTicket(),OrderLots(),Ask,5*PipMultiplier,Red);}
*/
//------   
   if(tral==-1) {//виртуальный трейлинг селл ордера 
   op=OrderOpenPrice(); 
   while (!IsTradeAllowed()) Sleep(500);  RefreshRates();  ask = Ask;
     
      if(Virtual_stop_sell1==0 ){
        if(op-ask > TrSt*PipMultiplier*p ) Virtual_stop_sell1 = op + TrSt*PipMultiplier*p;//вирт.безубыток
                                           Print("Рисуем линию stop_sell1 на уровне ",Virtual_stop_sell1);
                                             Set_line_sell1(Virtual_stop_sell1, Red);}
     if(Virtual_stop_sell1>0){
        if(ask>Virtual_stop_sell1)
          {if(OrderClose(OrderTicket(),OrderLots(),Ask,5*PipMultiplier,Blue)){ DeletAll_line(); break;}}
        if(op-ask > TrSt*PipMultiplier*p &&  ask+TrSt*PipMultiplier*p < Virtual_stop_sell1) 
          {Virtual_stop_sell1 =ask+TrSt*PipMultiplier*p; Set_line_sell1(Virtual_stop_sell1, Red);}}//вирт.трал
    }
   //----------
if(  tral==1){// сейчас будем реально тралить селл ордер
   op=OrderOpenPrice(); stop=OrderStopLoss(); mod_stop=stop;
   while (!IsTradeAllowed()) Sleep(500);  RefreshRates();    ask = Ask;
  if(op-ask > TrSt*PipMultiplier*p && (stop > ask+TrSt*PipMultiplier*p ||stop==0)) mod_stop= ask +TrSt*PipMultiplier*p;//трал
  if((mod_stop < stop ||stop==0) && mod_stop < op && mod_stop-ask > minstop*p)
  if(!OrderModify(OrderTicket(),op,NormalizeDouble(mod_stop,Digits), OrderTakeProfit(),0))
      Print("Не получилось переставить стоп, ошибка  " ,GetLastError());
    else {Virtual_stop_buy1=0;Virtual_stop_sell1=0;DeletAll_line();}
   }
}}}
//----------------------ГРАФИКА ВИРТУАЛЬНОГО ТРАЛА-----------------------------
void Set_line_buy1(double level, color Color){
if(ObjectFind(line_buy1)!= -1)ObjectDelete(line_buy1); 
createline_buy1 = ObjectCreate(line_buy1, OBJ_HLINE, 0, 0, level);
                  ObjectSet(line_buy1,OBJPROP_COLOR,Color);}
//------------------
void Set_line_sell1(double level, color Color){
if(ObjectFind(line_sell1)!= -1)ObjectDelete(line_sell1); 
createline_sell1 = ObjectCreate(line_sell1, OBJ_HLINE, 0, 0, level);
                   ObjectSet(line_sell1,OBJPROP_COLOR,Color);}
//-------------------
void DeletAll_line(){
if(ObjectFind(line_buy1 )!= -1)ObjectDelete(line_buy1); 
if(ObjectFind(line_sell1)!= -1)ObjectDelete(line_sell1);
}
/*
//---------------------------takeprofit----------------------------------------
void Set_line_buy_profit(double level, color Color){
if(ObjectFind(line_buy_profit)!= -1)ObjectDelete(line_buy_profit); 
createline_buy_profit = ObjectCreate(line_buy_profit, OBJ_HLINE, 0, 0, level);
                  ObjectSet(line_buy_profit,OBJPROP_STYLE,STYLE_DOT);
                  ObjectSet(line_buy_profit,OBJPROP_COLOR,Color);}
//------------------
void Set_line_sell_profit(double level, color Color){
if(ObjectFind(line_sell_profit)!= -1)ObjectDelete(line_sell_profit); 
createline_sell_profit = ObjectCreate(line_sell_profit, OBJ_HLINE, 0, 0, level);
                   ObjectSet(line_sell_profit,OBJPROP_STYLE,STYLE_DOT);
                   ObjectSet(line_sell_profit,OBJPROP_COLOR,Color);}
//-------------------
void Delet_line_profit(){
if(ObjectFind(line_buy_profit )!= -1)ObjectDelete(line_buy_profit); 
if(ObjectFind(line_sell_profit)!= -1)ObjectDelete(line_sell_profit);
}
*/

