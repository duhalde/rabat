function sse = myfit(params,t,Actual_Output)
w = ones(length(t),1);
expf = 0.4;

Fitted_Curve = decay_model(params,t,expf,w);
Error_Vector = Fitted_Curve - Actual_Output;

sse = sum(Error_Vector.^2);

end