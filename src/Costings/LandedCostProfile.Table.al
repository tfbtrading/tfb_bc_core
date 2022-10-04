table 50340 "TFB Landed Cost Profile"
{
    DataClassification = CustomerContent;
    LookupPageId = "TFB Landed Cost Profile List";
    DrillDownPageId = "TFB Landed Cost Profile List";
    TableType = Normal;

    fields
    {
        field(1; "Code"; Code[20])
        {
            DataClassification = CustomerContent;

        }
        field(2; "Description"; Text[250])
        {
            DataClassification = CustomerContent;

        }
        field(3; "Est. Net Weight"; Decimal)
        {
            DataClassification = CustomerContent;
            Caption = 'Estimated Net Weight';

            trigger OnValidate()
            begin
                CalculateCosts();
            end;

        }
        field(4; "Pallets"; Integer)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalculateCosts();
            end;
        }
        field(5; "Financed"; Boolean)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalculateCosts();
            end;
        }
        field(17; "Def. Days Financed"; Integer)
        {
            DataClassification = CustomerContent;
            MinValue = 0;
            MaxValue = 100;
        }
        field(6; "Palletised"; Boolean)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalculateCosts();
            end;
        }
        field(7; "Purchase Type"; Enum "TFB PurchaseType")
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalculateCosts();
            end;
        }
        field(8; "Port Documents"; Decimal)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalculateCosts();
            end;
        }
        field(9; "Quarantine Fees"; Decimal)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalculateCosts();
            end;
        }
        field(10; "Ocean Freight"; Decimal)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalculateCosts();
            end;
        }
        field(11; "Scenario"; Code[20])
        {
            DataClassification = CustomerContent;
            TableRelation = "TFB Costing Scenario";
            ValidateTableRelation = true;

            trigger OnValidate()
            begin
                CalculateCosts();
            end;
        }
        field(12; "Pallet Cost"; Decimal)
        {
            Editable = False;

        }

        field(15; "Container Cost"; Decimal)
        {
            Editable = False;
        }
        field(18; "Direct Container Costs"; Decimal)
        {
            Editable = False;
        }
        field(16; "Per Weight Cost"; Decimal)
        {
            Editable = False;
        }
        field(13; "Fumigated"; Boolean)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalculateCosts();
            end;
        }
        field(14; "Apply Contingency"; Boolean)
        {
            DataClassification = CustomerContent;

            trigger OnValidate()
            begin
                CalculateCosts();
            end;
        }
        field(30; "Inspected"; Boolean)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                CalculateCosts();
            end;

        }
        field(40; "Demurrage Days"; DateFormula)
        {
            DataClassification = CustomerContent;

        }
        field(50; "Heat Treated"; Boolean)
        {
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                CalculateCosts();
            end;
        }
        field(60; "Freight Currency"; Code[10])
        {
            DataClassification = CustomerContent;
            TableRelation = Currency;
            ValidateTableRelation = true;

        }
        field(70; "Freight (LCY)"; Decimal)
        {
            DataClassification = CustomerContent;
            Editable = false;
        }
        field(80;"Import Duties Charged";Boolean)
        {
            DataClassification = CustomerContent;
            
        }

    }

    keys
    {
        key(PK; Code)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        fieldgroup(DropDown; Code, Description, "Ocean Freight", Fumigated, Inspected, "Heat Treated") { }
        fieldgroup(Brick; Code, Description, "Ocean Freight", Fumigated, Inspected, "Heat Treated") { }
    }

    var
        CS: Record "TFB Costing Scenario";
        TempPerPallet: Decimal;
        TempPerContainer: Decimal;
        ChargePerPallet: Decimal;
        ChargePerContainer: Decimal;
        ChargePerWeight: Decimal;
        DirectChargesExcluded: Decimal;

    /* 
           LCUnitCostLCY[1] := LCProfile."Pallet Cost" / Header."Pallet Qty";
                LCUnitCostLCY[2] := LCProfile."Direct Container Costs" / LCProfile.Pallets / Header."Pallet Qty"; */

    procedure CalculateUnitCostStandard(ItemWeight: Decimal; PalletQty: Integer; ExchRate: Decimal; CostingScenario: Record "TFB Costing Scenario"; isDirectContainer: Boolean; var CalcBaseDesc: TextBuilder): Decimal

    var
        LclTempPerPallet: Decimal;
        LclTempPerContainer: Decimal;
        TotalForContainer: Decimal;
        FreightLCY: Decimal;
        ChargesToBeExcludedIfDirect: Decimal; // Direct charges excluded are calculated per pallet
    begin

        If isDirectContainer then
            CalcBaseDesc.AppendLine('Calculating Director Container Price')
        else
            CalcBaseDesc.AppendLine('Calculating For Warehouse Shipment');

        CalcBaseDesc.AppendLine(StrSubstNo('Pallet Putaway of %1 and Labelling of %2', CostingScenario."Pallet Putaway Charge", CostingScenario.Labelling));



        If not Palletised then begin

            LclTempPerPallet += CostingScenario."Pallet Package Bundle";
            LclTempPerContainer += CostingScenario."Unpack Loose";
            CalcBaseDesc.AppendLine(StrSubstNo('Requires palletisation - pallet %1, container %2', CostingScenario."Pallet Package Bundle", CostingScenario."Unpack Loose"));
        end
        else begin
            LclTempPerPallet += (CostingScenario."Pallet In Charge" + CostingScenario."Pallet Putaway Charge" + CostingScenario.Labelling);
            CalcBaseDesc.AppendLine(StrSubstNo('Already palletised - just need pallet handling charge of %1', CostingScenario."Pallet In Charge" + CostingScenario."Pallet Putaway Charge" + LclTempPerPallet + CostingScenario.Labelling));
        end;

        if Inspected then
            LclTempPerContainer += CostingScenario."Inspection Charge";

        //Exclude total pallet costs having to do with accepting in pallet of goods

        ChargesToBeExcludedIfDirect := (LclTempPerPallet * Pallets);



        if "Purchase Type" = "Purchase Type"::Imported then begin
            LclTempPerContainer += CostingScenario."Customs Declaration";
            LclTempPerContainer += "Port Documents";
            LclTempPerContainer += "Quarantine Fees";
            LclTempPerContainer += CostingScenario."Port Cartage";
            if Financed then
                LclTempPerContainer += CostingScenario."Bank Charge";
            If "Freight Currency" <> '' then
                FreightLCY := "Ocean Freight" / ExchRate
            else
                FreightLCY := "Ocean Freight";

            LclTempPerContainer += FreightLCY;

            CalcBaseDesc.AppendLine(StrSubstNo('Added Additional Import Charges of %1 and Freight %2', CostingScenario."Customs Declaration" + "Port Documents" + "Quarantine Fees" + CostingScenario."Port Cartage", FreightLCY));
            if "Apply Contingency" then LclTempPerContainer += CostingScenario."Container Contingency";
            if Fumigated then LclTempPerContainer += CostingScenario.Fumigation;
            If "Heat Treated" then LclTempPerContainer += CostingScenario."Heat Treatment";

        end;


        TotalForContainer := (LclTempPerContainer + (LclTempPerPallet * Pallets));

        If isDirectContainer then
            TotalForContainer := TotalForContainer - ChargesToBeExcludedIfDirect;

        CalcBaseDesc.AppendLine(StrSubstNo('Calculated out total per unit costs of %1', TotalForContainer / ("Est. Net Weight" / ItemWeight)));
        Exit(TotalForContainer / ("Est. Net Weight" / ItemWeight));

    end;

    procedure CalculateCosts()

    var
        currency: record Currency;
        currency3: record "Currency Exchange Rate";

        LatestDate: date;
        ExchRate: Decimal;
    begin

        TempPerPallet := 0;
        TempPerContainer := 0;
        DirectChargesExcluded := 0;

        if Cs.get(Scenario) then begin
            TempPerPallet += cs."Pallet Putaway Charge";
            TempPerPallet += cs.Labelling;



            If not Palletised then begin

                TempPerPallet += cs."Shrink Wrapping";
                TempPerContainer += cs."Unpack Loose";

            end
            else
                TempPerPallet += cs."Pallet In Charge";



            //Exclude total pallet costs having to do with accepting in pallet of goods

            If pallets > 0 then
                DirectChargesExcluded += TempPerPallet + (TempPerContainer / Pallets);

            if Financed then
                TempPerContainer += cs."Bank Charge";

            if "Purchase Type" = "Purchase Type"::Imported then begin
                TempPerContainer += cs."Customs Declaration";
                TempPerContainer += "Port Documents";
                TempPerContainer += "Quarantine Fees";
                TempPerContainer += cs."Port Cartage";


                If Rec."Freight Currency" <> '' then begin
                    currency.get(Rec."Freight Currency");
                    currency3.GetLastestExchangeRate("Freight Currency", LatestDate, ExchRate);
                    "Freight (LCY)" := "Ocean Freight" * ExchRate;
                end
                else
                    "Freight (LCY)" := "Ocean Freight";

                TempPerContainer += "Freight (LCY)";

                if "Apply Contingency" then TempPerContainer += cs."Container Contingency";
                if Fumigated then TempPerContainer += cs.Fumigation;
                If "Heat Treated" then TempPerContainer += cs."Heat Treatment";
            end;

            if Pallets > 0 then begin
                ChargePerContainer := TempPerContainer + (TempPerPallet * Pallets);
                ChargePerPallet := TempPerPallet + (TempPerContainer / Pallets);
            end;
            if "Est. Net Weight" > 0 then
                ChargePerWeight := ChargePerContainer / "Est. Net Weight"
            else
                ChargePerWeight := 0;

        end
        else begin

            ChargePerContainer := 0;
            ChargePerPallet := 0;
            ChargePerWeight := 0;
        end;

        "Container Cost" := ChargePerContainer;
        "Per Weight Cost" := ChargePerWeight;
        "Pallet Cost" := ChargePerPallet;
        "Direct Container Costs" := (ChargePerPallet - DirectChargesExcluded) * Pallets;



    end;


    procedure CalculateCostPerUnit(UnitWeight: decimal): Decimal
    var

        AmountToAllocate: Decimal;

    begin

        If (not rec.IsEmpty()) and ("Est. Net Weight" > 0) and (UnitWeight > 0) then
            AmountToAllocate := "Container Cost" / ("Est. Net Weight" / UnitWeight);

        Exit(AmountToAllocate);
    end;


    trigger OnModify()
    begin

    end;

}