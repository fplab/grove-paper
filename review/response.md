Thank you for your careful readings and thoughtful comments! We are heartened by the encouraging comments and strong overall assessment from RA and RB. 

We do not believe RC has identified any significant technical deficiencies in the work. We hope the clarifications we provide below will help illuminate some subtleties regarding our claimed contributions and the technical developments in the paper. We hope that this will lead to a more positive final assessment from RC as well.

# Review A

We agree with the detailed comments and will address them in the final version of the paper. 

# Review B

> My only (very minor) complaint is that as somewhat of an outsider to this space, I would have appreciated a longer and more detailed related works section, just to understand more about how the core ideas fit into the broader space. This is not a demand for a longer Related Works–I think the section is clearly already sufficient for acceptance. I only mention this because I think the paper could make a stronger case for its core ideas by offering a deeper analysis of the research space, especially for readers who are not already familiar with the relevant areas.

We agree, and we will fortify our discussion of related works in the final version of the paper. We intend to add further discussion of the literature on CRDTs and on patch synthesis approaches in version control systems in particular. 

# Review C

> For the first 18 pages, the paper develops a graph representation for representing
edits and various kinds of conflicts.

It is indeed the case that the central technical idea of the paper is a novel graph representation of collaboratively edited programs (L104), a corresponding patch calculus with commutative edits (L110), and a corresponding invertible decomposition into a grove (L116).

> The graph representation is essentially a different way of representing textual information by using special nodes and edge/node relations to represent conflicts.

Note that the graph representation captures information that cannot be represented in ordinary program text - namely, a subterm occurring in multiple places, multiple subterms in the same location, and a term containing itself as a subterm. To this end, the graph includes unique identifiers of vertices and edges, which are not contained in a typical textual representation. Our decomposition of the graph into groves, which may be presented "textually" to the user as in our implementation, was carefully structured to retain this information, as we prove in Agda.

> Compared to Hazelnut and Hazel, the only difference is that this paper assigns all conflicts to have the Dyn type from gradual typing. ... The idea of using Dyn types were already introduced in Hazel, so there is very little novelty here.

Section 5 on type checking was intended to be a "cherry on top" of the main contributions listed above. It is indeed the case that the type system is based directly on the marked lambda calculus, which is the core calculus of Hazel. However, the contribution of Section 5 is a bit more nuanced than is stated in this review:

- Local conflicts in synthetic position synthesize the dynamic type and generate constraints between this type and the synthesized types of the contents.
- Relocation and unicycle conflicts in synthetic position synthesize the dynamic type with provenance determined by the identifier they refer to. 
- Local conflicts in analytic positions analyze their contents against the same analyzed type.
- Relocation and unicycle conflicts in analytic position generate a constraint between the analyzed type and the dynamic type with provenance determined by the identifier they refer to.

These constraints allow the integration of typing information from all references to the same identifier. 

> The paper keeps on saying that "Grove does not suffer from problems due to merge conflicts". However, the only reason this is true is that Grove represents/encapsulates these conflicts. It does not solve any of the merging problems.

The paper does not claim that "Grove does not suffer from problems due to merge conflicts." On line 87, it claims that Grove "does not suffer from the problems just outlined," those problems being the granularity problem (L46), the relocation conflict problem (L52), and the relocation modification problem (L56). Each problem is addressed in Grove as described in Sec. 2.

The paper also states that "The Grove patch language is commutative, meaning that there is no need for a complex three-way merge algorithm (i.e. operational transform)" (L288). Again, this is not a claim that there are no problems due to merge conflicts, but rather that we do not need to rely on that particularly complex kind of algorithm to discover the merge conflicts.

We can see how these statements might not be as clear as possible in emphasizing that Grove does indeed represent/encapsulate merge conflicts without resolving them on the user's behalf fully automatically, and will expand on this in both the introduction and conclusion of the final version of the paper so that readers are less likely to misunderstand the claim. 

We believe that automatically resolving merge conflicts would require ad-hoc heuristics and inhibit user agency. Instead, Grove provides a setting in which those unresolved merge conflicts are syntactically and semantically meaningful. In particular, conflicts do not block edits from being made and shared with collaborators, and conflicts do not block the program's semantics. Previous version control systems require merge conflicts to be resolved before editor services may be available again, and Grove eliminates this gap problem by supporting editor services at all times. 

Automatic heuristics could be layered on top of Grove as a convenience, and indeed we mention a few possible situations where this might be helpful in the paper (e.g. in the paragraph on L390 and the next paragraph on L415). 

Details:

> Section 2.3.2 It is well known that tree-based editors handle the granularity problem better than line-based. But the tree-based editor has a much higher complexity, building the tree and maintaining the correct tree structure during edits such as cut and paste.

Hazel is a structured editor, so the tree structure of the program is maintained natively in the editor. It's true that this is more complex than just maintaining a string, but this complexity is accepted and handled in other aspects of Hazel's theory and implementation (e.g. Omar et al., 2017, Moon et al., 2023). There are a number of successful structure editors in popular usage, e.g. Scratch.

> Section 2.3.3 Grove chooses to silently merge changes from relocation modification, which current versioning control systems often yield a merge conflict. However, it is hard to say that this behavior is always wanted or preferred. In many scenarios, the involved programmers may want to review before such merges are committed. Also, this example seems to work well because the operations involved, + and *, are commutative. What if we have operations like - and /?

The key point here is that Alice's and Bob's edits are not in conflict with each other - one is modifying an expression, and the other is modifying the location of that expression. We posit that in practice, such actions are morally independent, even though they affect some of the same parts of the tree. We acknowledge, however, that in some cases like these it may be helpful to notify the users of the proximity of the edits. Such a notification system would not affect the underlying theory. We will note this possibility in the next version of the submission. 

When two edits are truly in conflict, meaning there is no way to apply them both and maintain a correct syntax tree, then Grove 'merges' them, but not silently - it results in a syntactically marked conflict. 

The commutativity of the operator here does not matter -- Grove operates purely syntactically. 

> Figure 10(d), why not add an L edge from +8 to *2 and a R edge from +8 to *24? Also, why R31 and not R35 and L33 not L37?

The R edge from +8 to *24 is not kept in 10(d) for the same reason that it is not kept in 10(b) - because Alice's action is to relocate *24, which involves both adding an edge and deleting an edge. When this same action is played back on 10(c), the R27 edge is deleted. Playing back all of the merged actions ensures commutativity. The edge names are different for a similar reason - the actions depicted delete and insert edges, so the final edges are new and have new identifiers. 

> What is the connection between Line 367 and Line 531? Earlier it says a disconnected term may be connected back after a deletion but later it says deleted edges can't connect again. Also, since an edge includes a term, the deletion of the edge also causes the deletion of the term if it is connected to by only one edge.

Deleting an edge does not delete any vertices. A term may be disconnected by deleting an edge and may be reconnected by inserting a new edge with the same origin and destination but a different identifier. The old edge remains deleted, but the term is reconnected. An edge does not include a term - it refers to an origin location and destination vertex.

> In Rule MKSLocalConflict, it is possible to synthesize a more precise type than ?. A more meaningful choice is the least upper bound of all σi's in terms of some subtyping relation. For example, if all branches of a conflict have Int, then it is fine to say that the conflict has the type Int.

This is true, and we considered taking this approach. We decided not to because it is more complete and modular to defer to the type hole inference system by emitting constraints that each synthesized type from the contents must be equal to the synthesized gradual type (and hence to each other). This allows the type hole inference system to indeed infer Int if they all have type Int, as well as to infer more complete information than the least upper bound would. 

> In rules MALocalConflict, MARelationConflict, and MAUnicycleConflict, why do you generate a constraint between a ? and σ? In gradual typing, such constraints are simply dropped. Probably you want to use the location for provenance. However, it is unclear how the location associated with each ? is used.

Indeed, such constraints are not dropped, and indeed we use the location for provenance. This section extends the work on the marked lambda calculus and type hole inference presented in Zhao et al., 2024. This prior work describes the details of how the provenances and constraints are solved and used. To summarize, constraints are solved with each instance of the gradual type from a specific provenance as a metavariable. This allows constraints on the same provenance originating at different points in the bidirectional flow to be combined to form a solution. If solved, this solution is returned to the bidirectional typing flow, and if conflicts are found, the possible solutions for type holes in the surface syntax are offered to the user as an editing affordance. 

As it happens, the constraint generated in the rule MALocalConflict is actually redundant because the hole with provenance $\exp(\ell)$ cannot appear in any other constraints generated by the program. This unnecessary constraint will be removed in the final version of the paper. We will also streamline the rules by altering MSLocalConflict to analyze the contents against the synthesized gradual type rather than generating constraints directly. Neither of these is an issue of correctness, but each represents an improvement to the presentation. 

Typos:

> Line 163, what does "this work" refer to? Probably it refers to Hazelnut and Hazel, but it is good to be explicit

"This work" refers to "the previous work on the Hazelnut structure editor calculus" (L139), and more specifically, "a type system and type error localization system (the marked lambda calculus) for incomplete programs" (L140) mentioned in the previous paragraph. We will make this reference more explicit in the next version of the submission. 

> Lemma 3.8, I am not sure if this is actually correct. For example \*24 in Figure 9(d) is both an MP and a U root.

Lemma 3.8 is correct. \*24 in Figure 9(d) is an MP root, but it is not a U root because there is no nontrivial sequence of vertices that begins and ends at \*24 such that each vertex is the *unique* parent of the previous. \*24 does not have a unique parent - it has multiple parents. 