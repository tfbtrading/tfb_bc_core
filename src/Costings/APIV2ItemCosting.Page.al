page 50335 "TFB APIV2 Item Costing"
{
    PageType = API;
    caption = 'itemCosting';
    APIPublisher = 'tfb';
    APIVersion = 'v2.0';
    APIGroup = 'costings';
    EntityName = 'itemCosting';
    EntitySetName = 'itemCostings';
    DelayedInsert = true;
    SourceTable = "TFB Item Costing";
    Editable = false;
    ODataKeyFields = SystemId;
    ApplicationArea = All;



    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'id';
                }
                field(itemNo; Rec."Item No.")
                {
                    Caption = 'itemNo';
                }
                field(description; Rec."Description")
                {

                    Caption = 'description';
                }
                field(costingType; Rec."Costing Type")
                {

                    Caption = 'costingType';
                }
                field(effectiveDate; Rec."Effective Date")
                {

                    Caption = 'effectiveDate';
                }
                field(purchasePriceUnit; Rec."Purchase Price Unit")
                {

                    Caption = 'purchasePriceUnit';
                }
                field(avgCost; Rec."Average Cost")
                {

                    Caption = 'iavgCost';
                }
                field(mktPrice; Rec."Market Price")
                {

                    Caption = 'mktPrice';

                }
                field(pricingMargin; Rec."Pricing Margin %")
                {

                    Caption = 'pricingMargin';

                }

                field(marketPricingMargin; Rec."Market Price Margin %")
                {

                    Caption = 'marketPricingMargin';

                }
                field(lastModified; Rec."Last Modified Date Time")
                {
                    Caption = 'lastModified';
                }
                field("hasLines"; Rec."HasLines")
                {
                    Caption = 'hasLines';

                }
                field(exwUnitPrice; Rec."Exw Unit")
                {
                    Caption = 'exwUnitPrice';

                }
                field(exwKgPrice; Rec."Exw Kg")
                {
                    Caption = 'exwKgPrice';

                }
                field(melMetroUnitPrice; Rec."Mel Metro Unit")
                {
                    Caption = 'elMetroUnitPrice';



                }
                field(melMetroKgPrice; Rec."Mel Metro Kg")
                {
                    Caption = 'melMetroKgPrice';
                }
                field(sydMetroUnitPrice; Rec."Syd Metro Unit")
                {
                    Caption = 'sydMetroUnitPrice';
                }
                field(sydMetroKgPrice; Rec."Adl Metro Unit")
                {
                    Caption = 'sydMetroKgPrice';
                }
                field(brsMetroUnitPrice; Rec."Brs Metro Unit")
                {
                    Caption = 'brsMetroUnitPric';
                }
                field(brsMetroKgPrice; Rec."Brs Metro Kg")
                {
                    Caption = 'brsMetroKgPrice';
                }

            }
        }

    }


    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.Insert(true);

        Rec.Modify(true);
        exit(false);
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        Rec.Delete(true);

        exit(false);
    end;


}