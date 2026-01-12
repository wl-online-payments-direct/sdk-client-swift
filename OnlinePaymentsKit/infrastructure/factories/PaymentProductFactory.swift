/*
 * Do not remove or alter the notices in this preamble.
 *
 * Copyright © 2026 Worldline and/or its affiliates.
 *
 * All rights reserved. License grant and user rights and obligations according to the applicable license agreement.
 *
 * Please contact Worldline for questions regarding license and user rights.
 */

import Foundation

internal class PaymentProductFactory: PaymentProductFactoryProtocol {

    private let validationRuleFactory = ValidationRuleFactory()

    // MARK: - BasicPaymentProducts

    func createBasicPaymentProducts(from dto: BasicPaymentProductsDto?) -> BasicPaymentProducts? {
        guard let dto = dto else {
            return nil
        }

        let products =
            dto.paymentProducts?.compactMap { productDto in
                createBasicPaymentProduct(from: productDto)
            } ?? []

        return BasicPaymentProducts(paymentProducts: products)
    }

    // MARK: - BasicPaymentProduct

    func createBasicPaymentProduct(from dto: BasicPaymentProductDto) -> BasicPaymentProduct {
        let id = dto.id

        // Extract and flatten displayHints
        let label = dto.displayHints?.label
        let logo = dto.displayHints?.logo
        let displayOrder = dto.displayHints?.displayOrder ?? Int.max

        // Transform accountsOnFile and filter by product ID
        let accountsOnFile = createAccountsOnFile(
            from: dto.accountsOnFile,
            forProductId: id
        )

        return BasicPaymentProduct(
            id: id,
            label: label,
            logo: logo,
            displayOrder: displayOrder,
            allowsTokenization: dto.allowsTokenization ?? false,
            allowsRecurring: dto.allowsRecurring ?? false,
            paymentMethod: dto.paymentMethod,
            paymentProductGroup: dto.paymentProductGroup,
            paymentProduct302SpecificData: dto.paymentProduct302SpecificData,
            paymentProduct320SpecificData: dto.paymentProduct320SpecificData,
            usesRedirectionTo3rdParty: dto.usesRedirectionTo3rdParty ?? false,
            accountsOnFile: accountsOnFile
        )
    }

    // MARK: - PaymentProduct

    func createPaymentProduct(from dto: PaymentProductDto) -> PaymentProduct {
        let id = dto.id

        // Extract and flatten displayHints
        let label = dto.displayHints?.label
        let logo = dto.displayHints?.logo
        let displayOrder = dto.displayHints?.displayOrder ?? Int.max

        // Transform accountsOnFile and filter by product ID
        let accountsOnFile = createAccountsOnFile(
            from: dto.accountsOnFile,
            forProductId: id
        )

        // Transform fields and sort by displayOrder
        let fields = createPaymentProductFields(from: dto.fields)

        return PaymentProduct(
            id: id,
            label: label,
            logo: logo,
            displayOrder: displayOrder,
            allowsTokenization: dto.allowsTokenization ?? false,
            allowsRecurring: dto.allowsRecurring ?? false,
            paymentMethod: dto.paymentMethod,
            paymentProductGroup: dto.paymentProductGroup,
            paymentProduct302SpecificData: dto.paymentProduct302SpecificData,
            paymentProduct320SpecificData: dto.paymentProduct320SpecificData,
            usesRedirectionTo3rdParty: dto.usesRedirectionTo3rdParty ?? false,
            accountsOnFile: accountsOnFile,
            fields: fields
        )
    }

    // MARK: - PaymentProductField

    private func createPaymentProductFields(from dtos: [PaymentProductFieldDto]?) -> [PaymentProductField] {
        guard let dtos = dtos else {
            return []
        }

        return dtos.map { dto in
            createPaymentProductField(from: dto)
        }.sorted { $0.displayHints.displayOrder < $1.displayHints.displayOrder }
    }

    internal func createPaymentProductField(from dto: PaymentProductFieldDto) -> PaymentProductField {
        let displayHints = createPaymentProductFieldDisplayHints(from: dto.displayHints)
        let dataRestrictions = createDataRestrictions(from: dto.dataRestrictions)
        let type = getFieldType(from: dto.type)

        return PaymentProductField(
            id: dto.id,
            type: type,
            displayHints: displayHints,
            dataRestrictions: dataRestrictions
        )
    }

    private func createPaymentProductFieldDisplayHints(
        from dto: PaymentProductFieldDisplayHintsDto
    ) -> PaymentProductFieldDisplayHints {
        let formElement = createFormElement(from: dto.formElement)
        let tooltip = createToolTip(from: dto.tooltip)

        return PaymentProductFieldDisplayHints(
            alwaysShow: dto.alwaysShow ?? false,
            displayOrder: dto.displayOrder ?? Int.max,
            formElement: formElement,
            label: dto.label,
            link: dto.link,
            mask: dto.mask,
            obfuscate: dto.obfuscate ?? false,
            placeholderLabel: dto.placeholderLabel,
            preferredInputType: dto.preferredInputType,
            tooltip: tooltip
        )
    }

    private func createFormElement(from dto: FormElementDto?) -> FormElement {
        guard let dto = dto else {
            return FormElement(type: .textType)
        }

        let type = getFormElementType(from: dto.type)
        return FormElement(type: type)
    }

    private func createToolTip(from dto: ToolTipDto?) -> ToolTip? {
        guard let dto = dto else {
            return nil
        }

        return ToolTip(label: dto.label)
    }

    internal func createDataRestrictions(from dto: DataRestrictionsDto?) -> DataRestrictions {
        let isRequired = dto?.isRequired ?? false
        let validationRules = validationRuleFactory.createRules(from: dto?.validators)

        return DataRestrictions(
            isRequired: isRequired,
            validationRules: validationRules
        )
    }

    // MARK: - AccountOnFile

    private func createAccountsOnFile(
        from dtos: [AccountOnFileDto]?,
        forProductId productId: Int?
    ) -> [AccountOnFile] {
        guard let dtos = dtos else {
            return []
        }

        return dtos.compactMap { dto in
            let accountProductId = dto.paymentProductId
            // If productId is nil, skip filtering
            if let productId = productId, accountProductId != productId {
                return nil
            }
            return createAccountOnFile(from: dto)
        }
    }

    internal func createAccountOnFile(from dto: AccountOnFileDto) -> AccountOnFile {
        let attributes = createAccountOnFileAttributes(from: dto.attributes)

        // Calculate label by applying mask to alias attribute
        let label = calculateAccountOnFileLabel(
            attributes: attributes,
            displayHints: dto.displayHints
        )

        return AccountOnFile(
            id: dto.id,
            paymentProductId: dto.paymentProductId,
            label: label,
            attributes: attributes
        )
    }

    private func createAccountOnFileAttributes(
        from dtos: [AccountOnFileAttributeDto]?
    ) -> [AccountOnFileAttribute] {
        guard let dtos = dtos else {
            return []
        }

        return dtos.map { dto in
            let status = getAccountOnFileAttributeStatus(from: dto.status)
            return AccountOnFileAttribute(
                key: dto.key,
                value: dto.value,
                status: status
            )
        }
    }

    private func calculateAccountOnFileLabel(
        attributes: [AccountOnFileAttribute],
        displayHints: AccountOnFileDisplayHintsDto?
    ) -> String? {
        let alias = attributes.first(where: { $0.key == "alias" })?.value

        guard let displayHints = displayHints,
            let labelTemplate = displayHints.labelTemplate
        else {
            return alias
        }

        let mask = labelTemplate.first(where: { $0.attributeKey == "alias" })?.mask

        return applyMask(mask: mask, to: alias) ?? alias
    }

    private func applyMask(mask: String?, to alias: String?) -> String? {
        guard let alias = alias, let mask = mask else {
            return alias
        }
        let formatter = StringFormatter()
        let formatted = formatter.formatString(string: alias, mask: mask)
        return formatted.trimmingCharacters(in: .whitespaces)
    }

    // MARK: - Enum Converters

    private func getFieldType(from typeString: String?) -> FieldType {
        switch typeString {
        case "string":
            return .string
        case "integer":
            return .integer
        case "expirydate":
            return .expirationDate
        case "numericstring":
            return .numericString
        case "boolean":
            return .boolString
        case "date":
            return .dateString
        default:
            let typeDescription = typeString ?? "nil"
            Logger.log("PaymentProductField type: \(typeDescription) is invalid")
            return .string
        }
    }

    private func getFormElementType(from typeString: String?) -> FormElementType {
        switch typeString {
        case "text":
            return .textType
        case "list":
            return .listType
        case "currency":
            return .currencyType
        case "date":
            return .dateType
        case "boolean":
            return .boolType
        default:
            return .textType
        }
    }

    private func getAccountOnFileAttributeStatus(from statusString: String?) -> AccountOnFileAttributeStatus {
        switch statusString {
        case "READ_ONLY":
            return .readOnly
        case "CAN_WRITE":
            return .canWrite
        case "MUST_WRITE":
            return .mustWrite
        default:
            if let status = statusString {
                Logger.log("AccountOnFileAttribute status: \(status) is invalid")
            }
            return .readOnly
        }
    }
}
