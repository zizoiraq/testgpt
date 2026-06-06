function Hdc = lambertian_gain(m,Adet,distance,phiDeg,psiDeg,FOVDeg,Ts,n)
%LAMBERTIAN_GAIN DC optical channel gain for LOS VLC link.
phi = deg2rad(phiDeg); psi = deg2rad(psiDeg); FOV = deg2rad(FOVDeg);
if abs(psi) > FOV
    Hdc = 0;
    return;
end
g = n^2/(sin(FOV)^2);
Hdc = ((m+1)*Adet/(2*pi*distance^2))*(cos(phi)^m)*Ts*g*cos(psi);
end
