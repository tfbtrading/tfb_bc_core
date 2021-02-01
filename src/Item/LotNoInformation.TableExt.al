tableextension 50280 "TFB Lot No. Information" extends "Lot No. Information"
{
    fields
    {
        field(50010; "TFB CoA Attachment"; Blob)
        {
            DataClassification = CustomerContent;
            Caption = 'CoA Attachment';
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced by persistent blob';
            ObsoleteTag = '#PersistentBlob';

        }
        field(50020; "TFB CoA Attached"; Boolean)
        {
            DataClassification = CustomerContent;
            Editable = False;
            Caption = 'CoA Attached';
            ObsoleteState = Pending;
            ObsoleteReason = 'Replaced by persistent blob';
            ObsoleteTag = '#PersistentBlob';

        }
        field(50015; "TFB CoA Attach."; BigInteger)
        {
            DataClassification = CustomerContent;
            Editable = false;
            Caption = 'CoA attached';

        }
        field(50018; "TFB OPC Attach."; BigInteger)
        {
            DataClassification = CustomerContent;
            Editable = false;
            Caption = 'OPC attached';

        }
        field(50030; "TFB Item Description"; Text[100])
        {
            Editable = False;
            DataClassification = CustomerContent;
            Caption = 'Description';
        }
        field(50040; "TFB Date Available"; Date)
        {
            Editable = True;
            Caption = 'Est. Date Available';
            DataClassification = CustomerContent;
        }
        field(50050; "TFB Last DateTime Modified"; DateTime)
        {
            Editable = false;
            Caption = 'Last DateTime Modified';
            DataClassification = CustomerContent;
        }
        field(50060; "TFB Last Date Modified"; Date)
        {
            Editable = false;
            Caption = 'Last Date Modified';
            DataClassification = CustomerContent;
        }


        modify("Item No.")
        {
            trigger OnAfterValidate()
            var
                Item: Record Item;
            begin
                Item.Get("Item No.");
                "TFB Item Description" := Item.Description;

            end;
        }

        modify(Blocked)
        {
            trigger OnAfterValidate()

            var

            begin

                If Rec.Blocked = false then
                    "TFB Date Available" := 0D;

            end;
        }


    }
    keys
    {
        key(TFBDesc; "TFB Item Description") { Enabled = true; }
    }

    trigger OnAfterModify()

    begin

        "TFB Last DateTime Modified" := CurrentDateTime();
        "TFB Last Date Modified" := Today();
    end;

    procedure UpdateItemDescriptions()
    var
        Item: Record Item;
        LotInfo: Record "Lot No. Information";


    begin

        Clear(LotInfo);

        if LotInfo.FindSet() then
            repeat
                Item.Get(LotInfo."Item No.");
                LotInfo."TFB Item Description" := Item.Description;
                LotInfo.Modify();

            until LotInfo.Next() < 1;

    end;



    procedure ToBase64String() ReturnValue: Text
    var
        TypeHelperCU: CodeUnit "Base64 Convert";
        FileText: Text;
        IStream: InStream;

    begin
        CalcFields("TFB CoA Attachment");
        if not "TFB CoA Attachment".HasValue() then
            exit;

        "TFB CoA Attachment".CreateInStream(IStream);
        IStream.ReadText(FileText);
        ReturnValue := TypeHelperCU.ToBase64(FileText);
    end;

}