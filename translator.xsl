<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="html" indent="yes" 
            doctype-public="-//W3C//DTD HTML 4.01//EN" 
            doctype-system="http://www.w3.org/TR/html4/strict.dtd"/>

<xsl:template match="/">
    <html>
        <head>
            <title>FMI IT Store</title>
            <style>
                body { font-family: Arial, sans-serif; margin: 20px; }
                .filters { margin-bottom: 20px; }
                .product { border: 1px solid #ddd; padding: 10px; margin: 10px; display: inline-block; width: 300px; }
                .product img { max-width: 200px; }
                .hidden { display: none; }
            </style>
            <script>
                function filterProducts() {
                    const type = document.getElementById('typeFilter').value;
                    const brand = document.getElementById('brandFilter').value;
                    const products = document.getElementsByClassName('product');
                    
                    for (let product of products) {
                        const productType = product.getAttribute('data-type');
                        const productBrand = product.getAttribute('data-brand');
                        product.classList.toggle('hidden', 
                            (type !== 'all' &amp;&amp; productType !== type) || 
                            (brand !== 'all' &amp;&amp; productBrand !== brand));
                    }
                }

                function sortProducts(criteria) {
                    const container = document.getElementById('products');
                    const products = [...container.getElementsByClassName('product')];
                    
                    products.sort((a, b) => {
                        if (criteria === 'price') {
                            const priceA = parseFloat(a.getAttribute('data-price'));
                            const priceB = parseFloat(b.getAttribute('data-price'));
                            return priceA - priceB;
                        } else {
                            const nameA = a.getAttribute('data-name');
                            const nameB = b.getAttribute('data-name');
                            return nameA.localeCompare(nameB);
                        }
                    });

                    products.forEach(product => container.appendChild(product));
                }
            </script>
        </head>
        <body>
            <div class="filters">
                <select id="typeFilter" onchange="filterProducts()">
                    <option value="all">All Types</option>
                    <xsl:for-each select="catalog/products/product/@xsi:type[not(. = preceding::product/@xsi:type)]">
                        <option value="{.}">
                            <xsl:value-of select="substring(., 1, string-length(.) - 4)"/>s
                        </option>
                    </xsl:for-each>
                </select>
                
                <select id="brandFilter" onchange="filterProducts()">
                    <option value="all">All Brands</option>
                    <xsl:for-each select="catalog/brands/brand">
                        <option><xsl:value-of select="."/></option>
                    </xsl:for-each>
                </select>
                
                <select onchange="sortProducts(this.value)">
                    <option value="name">Sort by Name</option>
                    <option value="price">Sort by Price</option>
                </select>
            </div>

            <div id="products">
                <xsl:apply-templates select="catalog/products/product"/>
            </div>
        </body>
    </html>
</xsl:template>

<xsl:template match="product">
    <div class="product">
        <xsl:attribute name="data-type">
            <xsl:value-of select="@xsi:type"/>
        </xsl:attribute>
        <xsl:attribute name="data-brand">
            <xsl:value-of select="brand"/>
        </xsl:attribute>
        <xsl:attribute name="data-name">
            <xsl:value-of select="name"/>
        </xsl:attribute>
        <xsl:attribute name="data-price">
            <xsl:choose>
                <xsl:when test="price/@currency = 'EUR'">
                    <xsl:value-of select="price * 1.95583"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="price"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
        
        <img>
            <xsl:attribute name="src">
                <xsl:value-of select="image/@src"/>
            </xsl:attribute>
        </img>
        <h3><xsl:value-of select="name"/></h3>
        <p>Brand: <xsl:value-of select="brand"/></p>
        <p>Price: <xsl:value-of select="price"/>
            <xsl:value-of select="price/@currency"/>
        </p>
        <xsl:apply-templates select="*[not(self::image or self::name or self::brand or self::price)]"/>
    </div>
</xsl:template>
</xsl:stylesheet>