table 50345 "TFB Item Costing"
{


    fields
    {
        field(99; "Estimate No."; GUID)
        {

            DataClassification = CustomerContent;
            ObsoleteState = Pending;
            ObsoleteReason = 'Superceded by systemid field';
        }
        field(1; "Item No."; Code[20])
        {
            Caption = 'Item Code';
            DataClassification = CustomerContent;
            TableRelation = Item;
            ValidateTableRelation = true;
            NotBlank = true;
            trigger OnValidate()
            var
                ItemRec: Record Item;
                LCProfile: Record "TFB Landed Cost Profile";
                LCScenario: Record "TFB Costing Scenario";
            begin
                ItemRec.Get("Item No.");
                Description := ItemRec.Description;
                if ItemRec."TFB Est. Storage Duration" > 0 then
                    "Est. Storage Duration" := ItemRec."TFB Est. Storage Duration"
                else
                    if LCProfile.get("Landed Cost Profile") then
                        if LCScenario.get(LCProfile.Scenario) then
                            "Est. Storage Duration" := LCScenario."Def. Storage Duration";

                if ItemRec."Vendor No." <> '' then
                    Validate("Vendor No.", ItemRec."Vendor No.");

                if CheckMandatoryFieldsValid() then CostingCU.GenerateCostingLines(rec) else DeleteCostings(rec);
            end;
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

            trigger OnValidate()

            begin
                CostingCU.CheckAndObseleteOldRecords(rec);
            end;
        }

        field(14; "Exch. Rate"; Decimal)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if CheckMandatoryFieldsValid() then CostingCU.GenerateCostingLines(rec) else DeleteCostings(rec);
            end;
        }

        field(15; "Pricing Margin %"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = true;
            trigger OnValidate()
            begin
                if CheckMandatoryFieldsValid() then CostingCU.GenerateCostingLines(rec) else DeleteCostings(rec);
            end;

        }
        field(16; "Market Price Margin %"; Decimal)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if CheckMandatoryFieldsValid() then CostingCU.GenerateCostingLines(rec) else DeleteCostings(rec);
            end;


        }
        field(22; "Full Load Margin %"; Decimal)
        {
            DataClassification = CustomerContent;

            Caption = 'Discount on Full Load';
            trigger OnValidate()
            begin
                if CheckMandatoryFieldsValid() then CostingCU.GenerateCostingLines(rec) else DeleteCostings(rec);
            end;


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


            trigger OnValidate()
            var
                LCProfile: Record "TFB Landed Cost Profile";
                LCScenario: Record "TFB Costing Scenario";

            begin
                if LCProfile.get("Landed Cost Profile") then begin

                    "Days Financed" := LCProfile."Def. Days Financed";

                    if LCScenario.get(LCProfile.Scenario) then
                        "Exch. Rate" := LCScenario."Exchange Rate";

                    "Market Price Margin %" := LCScenario."Market Price Margin %";
                    "Pricing Margin %" := LCScenario."Pricing Margin %";
                    "Full Load Margin %" := LCScenario."Full Load Margin %";


                    if CheckMandatoryFieldsValid() then CostingCU.GenerateCostingLines(rec) else DeleteCostings(rec);

                end;

            end;
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
            trigger OnValidate()
            begin
                if CheckMandatoryFieldsValid() then CostingCU.GenerateCostingLines(rec) else DeleteCostings(rec);
            end;



        }
        field(17; "Days Financed"; Integer)
        {
            //TODO: Need to figure out a way to migrate this to an actual duration field
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 180;

            trigger OnValidate()
            begin
                if CheckMandatoryFieldsValid() then CostingCU.GenerateCostingLines(rec) else DeleteCostings(rec);
            end;


        }
        field(18; "Dropship"; Boolean)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                if CheckMandatoryFieldsValid() then CostingCU.GenerateCostingLines(rec) else DeleteCostings(rec);
            end;



        }
        field(7; "Vendor No."; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = Vendor;
            ValidateTableRelation = true;

            trigger OnValidate()
            var
                Vendor: Record Vendor;
            begin
                Vendor.Get("Vendor No.");
                "Vendor Name" := Vendor.Name;
                "Purchase Price Unit" := Vendor."TFB Vendor Price Unit";

                if Vendor."TFB Landed Cost Profile" <> '' then begin
                    Validate("Landed Cost Profile", Vendor."TFB Landed Cost Profile");
                    if CheckMandatoryFieldsValid() then CostingCU.GenerateCostingLines(rec) else DeleteCostings(rec);
                end;

                CalcFields("Vendor Currency");

            end;
        }
        field(8; "Vendor Name"; text[200])
        {
            DataClassification = CustomerContent;
            TableRelation = Vendor;
            ValidateTableRelation = false;

            trigger OnValidate()

            var
                Vendor: Record Vendor;
            begin

                Validate("Vendor No.", Vendor.GetVendorNo(CopyStr("Vendor Name", 1, 100)));

            end;
        }
        field(13; "Purchase Price Unit"; enum "TFB Price Unit")
        {
            trigger OnValidate()
            begin
                if CheckMandatoryFieldsValid() then CostingCU.GenerateCostingLines(rec) else DeleteCostings(rec);
            end;


        }

        field(10; "Average Cost"; Decimal)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if CheckMandatoryFieldsValid() then CostingCU.GenerateCostingLines(rec) else DeleteCostings(rec);
            end;


        }
        field(11; "Market Price"; Decimal)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if CheckMandatoryFieldsValid() then CostingCU.GenerateCostingLines(rec) else DeleteCostings(rec);
            end;


        }
        field(12; "Pallet Qty"; Integer)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                if CheckMandatoryFieldsValid() then CostingCU.GenerateCostingLines(rec) else DeleteCostings(rec);
            end;


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
            trigger OnValidate()

            begin
                CostingCU.CheckAndObseleteOldRecords(rec);
            end;

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
        "Last Modified Date Time" := CURRENTDATETIME();

        if CheckMandatoryFieldsValid() then
            CostingCU.GenerateCostingLines(rec)
        else
            DeleteCostings(Rec);
    end;

    trigger OnInsert()
    begin


        if CheckMandatoryFieldsValid() then CostingCU.GenerateCostingLines(rec) else DeleteCostings(Rec);

    end;



    procedure CalcCostings(paramRec: record "TFB Item Costing")


    begin

        CostingCU.GenerateCostingLines(Rec);

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