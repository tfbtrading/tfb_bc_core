table 50345 "TFB Item Costing"
{
    ObsoleteState = Removed;
    ObsoleteReason = 'Replaced by TFB Item Costing Revised';

    fields
    {
        field(99; "Estimate No."; GUID)
        {

            DataClassification = CustomerContent;
            ObsoleteState = Removed;
            ObsoleteReason = 'Superceded by systemid field';
        }
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item Code';
            DataClassification = CustomerContent;
            TableRelation = Item;
            ValidateTableRelation = true;
            NotBlank = true;
            
        }
        field(5; "Description"; Text[250])
        {
            Caption = 'Item Description';
            DataClassification = CustomerContent;
            TableRelation = Item.Description;
            ValidateTableRelation = false;

            trigger OnValidate()

            var
                ItemRec: Record Item;
            begin

                Validate("Item No.", ItemRec.GetItemNo(Description));

            end;
        }
        field(41; "Item Category"; Code[20])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Item."Item Category Code" where("No." = field("Item No.")));
            Editable = false;


        }
        field(42; "Sale Blocked"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Item."Sales Blocked" where("No." = field("Item No.")));
            Editable = false;
        }
        field(44; "Publishing Blocked"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Item."TFB Publishing Block" where("No." = field("Item No.")));
            Editable = false;
        }
        field(50; "Automatically Updated"; Boolean)
        {
            InitValue = true;
            Editable = true;
            Caption = 'Automat. Updated';

        }

        field(2; "Costing Type"; Option)
        {
            OptionMembers = "Standard","Customer","Test";

        }
        field(3; "Effective Date"; Date)
        {
            NotBlank = true;

          
        }

        field(14; "Exch. Rate"; Decimal)
        {
            DataClassification = CustomerContent;

        
        }

        field(15; "Pricing Margin %"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = true;
         

        }
        field(16; "Market Price Margin %"; Decimal)
        {
            DataClassification = CustomerContent;
           

        }
        field(22; "Full Load Margin %"; Decimal)
        {
            DataClassification = CustomerContent;

            Caption = 'Discount on Full Load';
           


        }
        field(9; "Last Modified Date Time"; DateTime)
        {
            DataClassification = CustomerContent;
        }
        field(4; "Landed Cost Profile"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Landed Cost Profile";
            ValidateTableRelation = true;
            NotBlank = true;


          
        }

        field(60; "Scenario Override"; Code[20])
        {
            DataClassification = CustomerContent;

            TableRelation = "TFB Costing Scenario";
            ValidateTableRelation = true;
        }

        field(6; "Est. Storage Duration"; Duration)
        {
            DataClassification = CustomerContent;
         


        }
        field(17; "Days Financed"; Integer)
        {
            //TODO: Need to figure out a way to migrate this to an actual duration field
       
        }
        field(18; "Dropship"; Boolean)
        {
            DataClassification = CustomerContent;

          


        }
        field(7; "Vendor No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Vendor;
            ValidateTableRelation = true;

          
        }
        field(8; "Vendor Name"; text[200])
        {
            DataClassification = CustomerContent;
            TableRelation = Vendor;
            ValidateTableRelation = false;

         
        }
        field(13; "Purchase Price Unit"; enum "TFB Price Unit")
        {
          

        }

        field(10; "Average Cost"; Decimal)
        {
            DataClassification = CustomerContent;
         


        }
        field(11; "Market Price"; Decimal)
        {
            DataClassification = CustomerContent;
          


        }
        field(12; "Pallet Qty"; Integer)
        {
            DataClassification = CustomerContent;
          


        }
        field(19; "HasLines"; Boolean)
        {
            FieldClass = FlowField;
            CalcFormula = exist("TFB Item Costing Lines" where("Item No." = field("Item No."), "Costing Type" = field("Costing Type"), "Effective Date" = field("Effective Date")));

        }
        field(20; "Vendor Currency"; Code[10])
        {
            FieldClass = FlowField;
            CalcFormula = lookup(Vendor."Currency Code" where("No." = field("Vendor No.")));
        }
        field(23; "Current"; Boolean)
        {
            Editable = true;

            //Check for effective date and obselete old records if true
          

        }

        field(30; "Mel Metro Unit"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("TFB Item Costing Lines"."Price (Base)" where("Item No." = field("Item No."), "Costing Type" = const(Standard), "Effective Date" = field("Effective Date"), "Line Type" = const(DZP), "Line Key" = const('MELMETRO')));

        }
        field(31; "Mel Metro Kg"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("TFB Item Costing Lines"."Price Per Weight Unit" where("Item No." = field("Item No."), "Costing Type" = const(Standard), "Effective Date" = field("Effective Date"), "Line Type" = const(DZP), "Line Key" = const('MELMETRO')));

        }
        field(32; "Syd Metro Unit"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("TFB Item Costing Lines"."Price (Base)" where("Item No." = field("Item No."), "Costing Type" = const(Standard), "Effective Date" = field("Effective Date"), "Line Type" = const(DZP), "Line Key" = const('SYDMETRO')));

        }
        field(33; "Syd Metro Kg"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("TFB Item Costing Lines"."Price Per Weight Unit" where("Item No." = field("Item No."), "Costing Type" = const(Standard), "Effective Date" = field("Effective Date"), "Line Type" = const(DZP), "Line Key" = const('SYDMETRO')));

        }
        field(34; "Adl Metro Unit"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("TFB Item Costing Lines"."Price (Base)" where("Item No." = field("Item No."), "Costing Type" = const(Standard), "Effective Date" = field("Effective Date"), "Line Type" = const(DZP), "Line Key" = const('ADLMETRO')));

        }
        field(35; "Adl Metro Kg"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("TFB Item Costing Lines"."Price Per Weight Unit" where("Item No." = field("Item No."), "Costing Type" = const(Standard), "Effective Date" = field("Effective Date"), "Line Type" = const(DZP), "Line Key" = const('ADLMETRO')));

        }
        field(36; "Brs Metro Unit"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("TFB Item Costing Lines"."Price (Base)" where("Item No." = field("Item No."), "Costing Type" = const(Standard), "Effective Date" = field("Effective Date"), "Line Type" = const(DZP), "Line Key" = const('BRSMETRO')));

        }
        field(37; "Brs Metro Kg"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("TFB Item Costing Lines"."Price Per Weight Unit" where("Item No." = field("Item No."), "Costing Type" = const(Standard), "Effective Date" = field("Effective Date"), "Line Type" = const(DZP), "Line Key" = const('BRSMETRO')));

        }
        field(38; "Exw Unit"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("TFB Item Costing Lines"."Price (Base)" where("Item No." = field("Item No."), "Costing Type" = const(Standard), "Effective Date" = field("Effective Date"), "Line Type" = const(EXP)));

        }
        field(39; "Exw Kg"; Decimal)
        {
            FieldClass = FlowField;
            CalcFormula = sum("TFB Item Costing Lines"."Price Per Weight Unit" where("Item No." = field("Item No."), "Costing Type" = const(Standard), "Effective Date" = field("Effective Date"), "Line Type" = const(EXP)));

        }
        field(40; Id; GUID)
        {
            ObsoleteState = Pending;
            ObsoleteReason = 'Superceded by systemid field';

        }
        field(45; "Fix Exch. Rate"; Boolean)
        {
            Caption = 'Fix Exch. Rate';
            Editable = true;
        }


    }

    keys
    {

        key(PK; "Item No.", "Costing Type", "Effective Date")
        {
            Clustered = true;

        }
        key(Desc; Description)
        {

        }






    }
    trigger OnModify()
    begin
     
    end;

    trigger OnInsert()
    begin


    end;



    procedure CalcCostings(paramRec: record "TFB Item Costing")


    begin

    

    end;






    local procedure DeleteCostings(paramRec: record "TFB Item Costing")

    var
        ItemCostingLine: record "TFB Item Costing Lines";

    begin
        //Remove previous item cost lines
        ItemCostingLine.SetRange("Item No.", paramRec."Item No.");
        ItemCostingLine.SetRange("Costing Type", paramRec."Costing Type");
        ItemCostingLine.SetRange("Effective Date", paramRec."Effective Date");
        ItemCostingLine.DeleteAll();

    end;


    local procedure CheckMandatoryFieldsValid(): Boolean

    var
        TestFailed: Boolean;

    begin
        TestFailed := false;

        if ("Item No." = '') then TestFailed := true;

        if "Landed Cost Profile" = '' then TestFailed := true;

        if "Vendor No." = '' then TestFailed := true;

        if "Average Cost" = 0 then TestFailed := true;

        if "Pricing Margin %" = 0 then TestFailed := true;

        if "Market Price Margin %" = 0 then TestFailed := true;

        if "Market Price" = 0 then TestFailed := true;

        if "Full Load Margin %" = 0 then TestFailed := true;

        if "Pallet Qty" = 0 then TestFailed := true;

        if "Exch. Rate" = 0 then TestFailed := true;

        if TestFailed then exit(false) else exit(true);

    end;

    procedure GetRelatedScenario() Scenario: Record "TFB Costing Scenario"

    var
        LandedProfile: Record "TFB Landed Cost Profile";

    begin
        if not Scenario.Get(Rec."Scenario Override") then
            if LandedProfile.Get(Rec."Landed Cost Profile") then
                Scenario.Get(LandedProfile.Scenario);

    end;

    var
        CostingCU: CodeUnit "TFB Costing Mgmt";

}