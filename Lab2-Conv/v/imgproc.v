module imgproc(	oGrey_R,
				oGrey_G,
				oGrey_B,
				oDVAL,
				iX_Cont,
				iY_Cont,
				iDATA,
				iDVAL,
				iCLK,
				iRST,
				iSW
				);

input	[10:0]	iX_Cont;
input	[10:0]	iY_Cont;
input	[11:0]	iDATA;
input			iDVAL;
input			iCLK;
input			iRST;
input			iSW;
wire	[11:0]	oRed;
wire	[11:0]	oGreen;
wire	[11:0]	oBlue;
wire  [11:0] 	oGrey;
wire 	[11:0]   y;
wire 	[11:0]   abs_y;

output [11:0]  oGrey_R;
output [11:0]  oGrey_G;
output [11:0]  oGrey_B;

output			oDVAL;
wire	[11:0]	mDATA_0;
wire	[11:0]	mDATA_1;

wire 	[11:0]	cDATA_0;
wire 	[11:0]	cDATA_1;
wire 	[11:0]	cDATA_2;

reg		[11:0]	mDATAd_0;
reg		[11:0]	mDATAd_1;

reg 	[11:0]	cDATAd_0;
reg 	[11:0]	cDATAd_1;
reg 	[11:0]	cDATAd_2;

reg 	[11:0]	cDATAdd_0;
reg 	[11:0]	cDATAdd_1;
reg 	[11:0]	cDATAdd_2;

reg		[11:0]	mCCD_R;
reg		[12:0]	mCCD_G;
reg		[11:0]	mCCD_B;
reg				mDVAL;

assign	oRed	=	mCCD_R[11:0];
assign	oGreen	=	mCCD_G[12:1];
assign	oBlue	=	mCCD_B[11:0];


assign 	oGrey = (oRed + oGreen + oGreen + oBlue) / 4;
assign	oGrey_G = abs_y;
assign	oGrey_B = abs_y;
assign 	oGrey_R = abs_y;

assign	oDVAL	=	mDVAL;

Line_Buffer1 	u0	(	.clken(iDVAL),
						.clock(iCLK),
						.shiftin(iDATA),
						.taps0x(mDATA_1),
						.taps1x(mDATA_0)	);

Line_Buffer2 	u1 (	.clken(mDVAL),
						.clock(iCLK),
						.shiftin(oGrey),
						.taps0x(cDATA_0),
						.taps1x(cDATA_1),
						.taps2x(cDATA_2)	);

Convolution_Filter conv_filter(	iCLK,
				iSW,
				cDATAdd_0,	//input[11:0] X_INn1n1,
				cDATAd_0, //input[11:0] X_INz0n1,
				cDATA_0, //input[11:0] X_INp1n1,
				cDATAdd_1, //input[11:0] X_INn1z0,
				cDATAd_1, //input[11:0] X_INz0z0,
				cDATA_1, //input[11:0] X_INp1z0,
				cDATAdd_2, //input[11:0] X_INn1p1,
				cDATAd_2, //input[11:0] X_INz0p1,
				cDATA_2, //input[11:0] X_INp1p1,
				y
			);
			
Abs a1(y, abs_y);
						

always@(posedge iCLK or negedge iRST)
begin
	if(!iRST)
	begin
		mCCD_R	<=	0;
		mCCD_G	<=	0;
		mCCD_B	<=	0;
		mDATAd_0<=	0;
		mDATAd_1<=	0;
		cDATAd_0 <= 0;
		cDATAd_1 <= 0;
		cDATAd_2 <= 0;
		cDATAdd_0 <= 0;
		cDATAdd_1 <= 0;
		cDATAdd_2 <= 0;
		mDVAL	<=	0;
	end
	else
	begin
		mDATAd_0	<=	mDATA_0;
		mDATAd_1	<=	mDATA_1;
		cDATAd_0 <= cDATA_0;
		cDATAd_1 <= cDATA_1;
		cDATAd_2 <= cDATA_2;
		cDATAdd_0 <= cDATAd_0;
		cDATAdd_1 <= cDATAd_1;
		cDATAdd_2 <= cDATAd_2;
		mDVAL		<=	{iY_Cont[0]|iX_Cont[0]}	?	1'b0	:	iDVAL;
		if({iY_Cont[0],iX_Cont[0]}==2'b10)
		begin
			mCCD_R	<=	mDATA_0;
			mCCD_G	<=	mDATAd_0+mDATA_1;
			mCCD_B	<=	mDATAd_1;
		end	
		else if({iY_Cont[0],iX_Cont[0]}==2'b11)
		begin
			mCCD_R	<=	mDATAd_0;
			mCCD_G	<=	mDATA_0+mDATAd_1;
			mCCD_B	<=	mDATA_1;
		end
		else if({iY_Cont[0],iX_Cont[0]}==2'b00)
		begin
			mCCD_R	<=	mDATA_1;
			mCCD_G	<=	mDATA_0+mDATAd_1;
			mCCD_B	<=	mDATAd_0;
		end
		else if({iY_Cont[0],iX_Cont[0]}==2'b01)
		begin
			mCCD_R	<=	mDATAd_1;
			mCCD_G	<=	mDATAd_0+mDATA_1;
			mCCD_B	<=	mDATA_0;
		end
	end
end

endmodule


