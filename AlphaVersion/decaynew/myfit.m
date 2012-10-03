function sse = myfit(params,t,Actual_Output)

x = params;

w = ones(length(t),1);
expf = 0.4;

%Fitted_Curve = decay_model(params,t,expf,w);

y1 = x(1)*exp(x(2)*t); y2 = x(3);
Fitted_Curve  = w.*(y1.^2+y2.^2).^(0.5*expf);

Error_Vector = Fitted_Curve - Actual_Output;

sse = sum(Error_Vector.^2);

end