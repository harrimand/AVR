
function T0opt = T0config(SetF)
%  T0config(SetF) returns optimal MCU clock divisor and closest frequency
%  SetF = Target Frequency
%  T0opt 1x4 vector [clock prescaler, Counter frequency, Count Period, Max Delay]
%  Displays MCU clock prescaler, OCR0A value, Set Frequency, Output Frequency
%

    Fcpu = 16e6;
    T0bits = 8;
    T0max = 2^8-1;
%    SetF = 500;
    SetP = 1 / SetF;
    T0(:,1) = [1; 8; 64; 256; 1024];
    T0(:,2) = Fcpu ./ T0(:,1);
    T0(:,3) = 1 ./ T0(:,2);
    T0(:,4) = 2^T0bits * T0(:,3);
    if (SetP > T0(end))
        printf(' Set Frequency: %f\n', SetF);
        printf(' Minimum Frequency on Timer 2: %f\n', 1 / T0(end));
        T0opt = []
        return
    else        
        T0opt = T0(T0(:,4) == min(T0(T0(:,4)>SetP,4)),:);

        Labels = { 'Prescaler' 'T0_Freq' 'T0_Period' 'Max_Period' };
        CL = columnLabels(Labels, 5, 15);
        displayTable(CL, T0opt);

        OCR0Atarget = SetP / T0opt(3) - 1;
        OCR0Aset = round(OCR0Atarget);
        printf(' MCUclk / %d\n', cast(T0opt(1), 'uint16'));
        printf(' OCR0A = %d\n', cast(OCR0Aset, 'uint8'));
        printf(' Set Frequency = %d\n', SetF);
        printf(' Output Frequency = %f\n', 1 / ((OCR0Aset + 1) * T0opt(3)));
    end
end
