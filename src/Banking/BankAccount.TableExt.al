tableextension 50102 "TFB Bank Account" extends "Bank Account" //270
{
    fields
    {
        field(50100; "TFB No. Open Trans."; Integer)
        {
            Caption = 'No. Open Trans.';
            FieldClass = FlowField;
            CalcFormula = Count ("Bank Account Ledger Entry" where("Bank Account No." = Field("No."), Open = const(true), Reversed = const(false)));

        }

        field(50105; "TFB Latest Statement Date"; Date)
        {
            Caption = 'No. Open Trans.';
            FieldClass = FlowField;
            CalcFormula = max ("Bank Account Statement"."Statement Date" where("Bank Account No." = field("No.")));
        }

       
    }

}