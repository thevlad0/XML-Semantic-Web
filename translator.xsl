<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
<xsl:output method="html" indent="yes" 
            doctype-public="-//W3C//DTD HTML 4.01//EN" 
            doctype-system="http://www.w3.org/TR/html4/strict.dtd"/>

<!-- Main page template -->
<xsl:template match="/">
    <html>
        <head>
            <title>FMI IT Store</title>
            <style>
                .store-header {
                    text-align: center;
                    color: #2c3e50;
                    padding: 20px 0;
                    margin-bottom: 30px;
                    background: #ecf0f1;
                    border-bottom: 3px solid #3498db;
                }
                .store-header h1 {
                    font-size: 2.5em;
                    margin: 0;
                    text-transform: uppercase;
                    letter-spacing: 2px;
                }
                body { font-family: Arial, sans-serif; margin: 20px; }
                .filters { 
                    margin-bottom: 20px;
                    text-align: center;
                }
                .product { 
                    border: 1px solid #ddd; 
                    padding: 10px; 
                    margin: 10px; 
                    display: inline-block; 
                    width: 300px;
                    height: 350px;
                    vertical-align: top;
                    overflow: hidden;
                    position: relative;
                }
                .product img { 
                    width: 180px; 
                    height: 180px; 
                    object-fit: contain;
                    display: block;
                    margin: 0 auto;
                }
                .product p:last-child {
                    position: absolute;
                    bottom: 10px;
                    right: 10px;
                    margin: 0;
                    font-weight: bold;
                }
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

                function sortProducts(criteria, ascending = true) {
                    const container = document.getElementById('products');
                    const products = [...container.getElementsByClassName('product')];
                    
                    products.sort((a, b) => {
                        if (criteria === 'price') {
                            const priceA = parseFloat(a.getAttribute('data-price'));
                            const priceB = parseFloat(b.getAttribute('data-price'));
                            return ascending ? priceA - priceB : priceB - priceA;
                        } else {
                            const nameA = a.getAttribute('data-name');
                            const nameB = b.getAttribute('data-name');
                            return ascending ? nameA.localeCompare(nameB) : nameB.localeCompare(nameA);
                        }
                    });

                    products.forEach(product => container.appendChild(product));
                }
            </script>
        </head>
        <body>
            <div class="store-header">
                <h1>FMI IT Store</h1>
            </div>
            <div class="filters">
                <h3>Filter and Sort Options</h3>
                <select id="typeFilter" onchange="filterProducts()">
                    <option value="all">All Types</option>
                    <xsl:for-each select="catalog/products/product/@xsi:type[not(. = preceding::product/@xsi:type)]">
                        <option value="{.}">
                            <xsl:value-of select="concat(
                                translate(substring(., 1, 1), 'abcdefghijklmnopqrstuvwxyz', 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'),
                                substring(., 2, string-length(.) - 5),
                                's'
                            )"/>
                        </option>
                    </xsl:for-each>
                </select>
                
                <select id="brandFilter" onchange="filterProducts()">
                    <option value="all">All Brands</option>
                    <xsl:for-each select="catalog/brands/brand">
                        <option><xsl:value-of select="."/></option>
                    </xsl:for-each>
                </select>
                
                <select onchange="sortProducts(this.value.split('-')[0], this.value.split('-')[1] === 'asc')">
                    <option value="name-asc">Sort by Name (A-Z)</option>
                    <option value="name-desc">Sort by Name (Z-A)</option>
                    <option value="price-asc">Sort by Price (Low to High)</option>
                    <option value="price-desc">Sort by Price (High to Low)</option>
                </select>
            </div>

            <xsl:apply-templates select="catalog/products"/>
        </body>
    </html>
</xsl:template>

<!-- Load sorted products template -->
<xsl:template match="products">
    <div id="products">
        <xsl:for-each select="product">
            <xsl:sort select="name"/>
            <xsl:apply-templates select="."/>
        </xsl:for-each>
    </div>
</xsl:template>

<!-- Product load template -->
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
        <p>Model: <xsl:value-of select="model"/></p>
        <p>Price: <xsl:value-of select="price"/>
            <xsl:value-of select="price/@currency"/>
        </p>
    </div>
</xsl:template>
</xsl:stylesheet>